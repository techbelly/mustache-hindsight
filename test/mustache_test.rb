require_relative 'helper'
require 'json'

class MustacheTest < Minitest::Test
  def test_classify
    assert_equal 'TemplatePartial', Mustache.classify('template_partial')
    assert_equal 'Admin::TemplatePartial', Mustache.classify('admin/template_partial')
  end

  def test_underscore
    assert_equal 'template_partial', Mustache.underscore('TemplatePartial')
    assert_equal 'admin/template_partial', Mustache.underscore('Admin::TemplatePartial')
    assert_equal 'views/in/sub/directories', Mustache.underscore('Views::In::Sub::Directories')
  end

  def test_anon_subclass_underscore
    klass = Class.new(TemplatePartial)
    assert_equal 'template_partial', klass.underscore
  end

  def test_namespaced_underscore
    Object.const_set(:Views, Class.new)
    klass = Class.new(Mustache)
    klass.view_namespace = Views
    assert_equal 'stat_stuff', klass.underscore('Views::StatStuff')

    assert_equal 'views/stat_stuff', Mustache.underscore('Views::StatStuff')
  end

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
