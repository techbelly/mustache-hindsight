require 'strscan'

class Mustache
  class Parser
    class SyntaxError < StandardError
      def initialize(message, position)
        @message = message
        @lineno, @column, @line, _ = position
        @stripped_line = @line.strip
        @stripped_column = @column - (@line.size - @line.lstrip.size)
      end

      def to_s
        <<-EOF
#{@message}
  Line #{@lineno}
    #{@stripped_line}
    #{' ' * @stripped_column}^
EOF
      end
    end

    VALID_TYPES = [ '#', '^', '/', '=', '!', '<', '>', '&', '{' ].map(&:freeze)

    def self.valid_types
      @valid_types ||= Regexp.new(VALID_TYPES.map { |t| Regexp.escape(t) }.join('|') )
    end

    def self.add_type(*types, &block)
      types = types.map(&:to_s)
      type, *aliases = types
      method_name = "scan_tag_#{type}".to_sym
      define_method(method_name, &block)
      aliases.each { |a| alias_method "scan_tag_#{a}", method_name }
      types.each { |t| VALID_TYPES << t unless VALID_TYPES.include?(t) }
      @valid_types = nil
    end

    ALLOWED_CONTENT = /(\w|[?!\/.@-])*/

    ANY_CONTENT = [ '!', '=' ].map(&:freeze)

    attr_reader :otag, :ctag

    def initialize(options = {})
      @options = options
      @option_inline_partials_at_compile_time = options[:inline_partials_at_compile_time]

      self.otag ||= '{{'
      self.ctag ||= '}}'
    end

    def otag=(value)
      regex = regexp value
      @otag_regex     = /([ \t]*)?#{regex}/
      @otag_not_regex = /(^[ \t]*)?#{regex}/
      @otag = value
    end

    def ctag=(value)
      @ctag_regex = regexp value
      @ctag = value
    end

    def compile(template)
      @encoding = nil

      if template.respond_to?(:encoding)
        @encoding = template.encoding
        template = template.dup.force_encoding("BINARY")
      end

      @sections = []
      @result = [:multi]
      @scanner = StringScanner.new(template)

      until @scanner.eos?
        scan_tags || scan_text
      end

      unless @sections.empty?
        type, pos, _ = @sections.pop
        error "Unclosed section #{type.inspect}", pos
      end

      @result
    end

    private

    def content_tags type, current_ctag_regex
      if ANY_CONTENT.include?(type)
        r = /\s*#{regexp(type)}?#{current_ctag_regex}/
        scan_until_exclusive(r)
      else
        @scanner.scan(ALLOWED_CONTENT)
      end
    end

    def dispatch_based_on_type type, content, fetch, padding, pre_match_position
      send("scan_tag_#{type}", content, fetch, padding, pre_match_position)
    end

    def scan_tags
      start_of_line = @scanner.beginning_of_line?
      pre_match_position = @scanner.pos
      last_index = @result.length

      return unless @scanner.scan @otag_regex
      padding = @scanner[1] || ''

      unless start_of_line
        @result << [:static, padding] unless padding.empty?
        pre_match_position += padding.length
        padding = ''
      end

      current_ctag_regex = @ctag_regex
      type = @scanner.scan(self.class.valid_types)
      @scanner.skip(/\s*/)

      content = content_tags(type, current_ctag_regex)

      error "Illegal content in tag" if content.empty?

      fetch = [:mustache, :fetch, content.split('.')]
      prev = @result

      dispatch_based_on_type(type, content, fetch, padding, pre_match_position)
    end

    def scan_text
      text = scan_until_exclusive @otag_not_regex

      if text.nil?
        text = @scanner.rest
        @scanner.terminate
      end

      text.force_encoding(@encoding) if @encoding

      @result << [:static, text] unless text.empty?
    end

    def scan_until_exclusive(regexp)
      pos = @scanner.pos
      if @scanner.scan_until(regexp)
      end
    end

    def position
      rest = @scanner.check_until(/\n|\Z/).to_s.chomp

      parsed = @scanner.string[0...@scanner.pos]

      lines = parsed.split("\n")

      [ lines.size, lines.last.size - 1, lines.last + rest ]
    end

    def regexp(thing)
      Regexp.new Regexp.escape(thing) if thing
    end

    def error(message, pos = position)
      raise SyntaxError.new(message, pos)
    end

    def scan_tag_close content, fetch, padding, pre_match_position
      section, pos, result = @sections.pop
      if section.nil?
        error "Closing unopened #{content.inspect}"
      end
    end
    alias_method :'scan_tag_/', :scan_tag_close

    def scan_tag_comment content, fetch, padding, pre_match_position
    end
    alias_method :'scan_tag_!', :scan_tag_comment
  end
end
