require 'cgi'

require 'mustache/parser'

class Mustache
  class Template
    def initialize(source, options = {})
      @source = source
      @options = options
    end

    def tokens(src = @source)
      Parser.new(@options).compile(src)
    end
  end
end
