require_relative 'helper'

class PartialTest < Minitest::Test
  def test_recursive_partials
    assert_equal <<-end_partial, Recursive.render
It works!
end_partial
  end
end

class InnerThing < Mustache
  def partial(p) self.class end
  def name;      self.class end
end

class OuterThing < Mustache
  def inner
    InnerThing.new
  end

  def partial(p) self.class end
  def name;      self.class end
end

class MiddleThing < Mustache
  def partial(name) "{{#{name}}}" end
  def some_partial; "ok" end
end
