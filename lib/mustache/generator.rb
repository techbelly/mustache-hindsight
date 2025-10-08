class Mustache
  class Generator
    def initialize(options = {})
      @options = options
      @option_static_lambdas = options[:static_lambdas] == true
    end

    def compile(exp)
      "\"#{compile!(exp)}\""
    end

    private

    def compile!(exp)
      case exp.first
      when :multi
        exp[1..-1].reduce("".dup) { |sum, e| sum << compile!(e) }
      when :static
        str(exp[1])
      end
    end

    def str(s)
      s.inspect[1..-2]
    end
  end
end
