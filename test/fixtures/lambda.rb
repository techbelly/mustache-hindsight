require 'mustache'

class Lambda < Mustache
  self.path = File.dirname(__FILE__)

  attr_reader :calls

  def initialize(*args)
    super
    @calls = 0
    @cached = nil
  end

  def rendered
    lambda do |text|
      return @cached if @cached

      @calls += 1
      @cached = render(text)
    end
  end

  def not_rendered
    lambda { |text| "{{= | =}}#{text}" }
  end
end
