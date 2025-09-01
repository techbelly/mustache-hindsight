require_relative 'helper'
require 'json'

class MustacheTest < Minitest::Test
  def test_knows_when_its_been_compiled_when_set_with_string
    klass = Class.new(Mustache)

    refute klass.compiled?
    klass.template = 'Hi, {{person}}!'
    assert klass.compiled?
  end

  def test_inherited_attributes
    Object.const_set :TestNamespace, Module.new
    base = Class.new(Mustache)
    tmpl = Class.new(base)

    {:template_extension => 'stache',
     :view_namespace     => TestNamespace,
     :view_path          => './foo'
     }.each do |attr, value|
      base.send("#{attr}=", value)
      assert_equal value, tmpl.send(attr)
    end
    attr = :template_path
    value = File.expand_path('./foo')
    base.send("#{attr}=", value)
    assert_equal value, tmpl.send(attr).first
  end
end
