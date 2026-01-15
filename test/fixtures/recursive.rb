require 'mustache'

class Recursive < Mustache
  self.path = File.dirname(__FILE__)

  def show
    false
  end
end
