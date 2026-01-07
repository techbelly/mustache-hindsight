require 'mustache'

class Unescaped < Mustache
  self.path = File.dirname(__FILE__)

  def title
    "Bear > Shark"
  end
end
