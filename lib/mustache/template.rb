require 'cgi'

require 'mustache/parser'

class Mustache
  class Template
    def initialize(source, options = {})
      @source = source
      @options = options
    end
  end
end
