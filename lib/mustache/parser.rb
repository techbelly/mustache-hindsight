require 'strscan'

class Mustache
  class Parser
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

    private

    def regexp(thing)
      Regexp.new Regexp.escape(thing) if thing
    end

    def scan_tag_comment content, fetch, padding, pre_match_position
    end
    alias_method :'scan_tag_!', :scan_tag_comment
  end
end
