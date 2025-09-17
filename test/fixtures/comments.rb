require 'mustache'

class Comments < Mustache
  self.path = File.dirname(__FILE__)

  def title
    "A Comedy of Errors"
  end
end
