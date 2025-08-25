require 'cgi'

class Mustache
  class Template
    def initialize(source, options = {})
      @source = source
      @options = options
    end
  end
end
