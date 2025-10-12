require 'cgi'

require 'mustache/parser'
require 'mustache/generator'

class Mustache
  class Template
    def initialize(source, options = {})
      @source = source
      @options = options
    end

    def render(context)
      compiled = "def render(ctx) #{compile} end"

      instance_eval(compiled, __FILE__, __LINE__ - 1)

      render(context)
    end

    def compile(src = @source)
      Generator.new(@options).compile(tokens(src))
    end
    alias_method :to_s, :compile

    def tokens(src = @source)
      Parser.new(@options).compile(src)
    end
  end
end
