require_relative 'helper'
require 'json'

class MustacheTest < Minitest::Test
  def test_fileless_templates
    view = Simple.new
    view.template = 'Hi {{person}}!'
    view[:person]  = 'mom'

    assert_equal 'Hi mom!', view.render
  end

  def test_unescaped_ampersand
    view = Mustache.new
    view.template = "<h1>{{& title}}</h1>"
    view[:title] = "Bear > Shark"
    assert_equal '<h1>Bear > Shark</h1>', view.render
  end

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

  def test_render
    assert_equal 'Hello World!', Mustache.render('Hello World!')
  end

  def test_render_with_params
    assert_equal 'Hello World!', Mustache.render('Hello {{planet}}!', :planet => 'World')
  end

  def test_render_from_file
    expected = <<-data
<VirtualHost *>
  ServerName example.com
  DocumentRoot /var/www/example.com
  RailsEnv production
</VirtualHost>
data
    template = File.read(File.dirname(__FILE__) + "/fixtures/passenger.conf")
    assert_equal expected, Mustache.render(template, :stage => 'production',
                                                     :server => 'example.com',
                                                     :deploy_to => '/var/www/example.com' )
  end

  def test_reports_unclosed_sections
    instance = Mustache.new
    instance[:list] = [ :item => 1234 ]
    instance.template = '{{#list}} <li>{{item}}</li> {{/gist}}'

    begin
      instance.render
    rescue => e
    end

    assert e.message.include?('Unclosed section')
  end

  def test_unclosed_sections_reports_the_line_number
    instance = Mustache.new
    instance[:list] = [ :item => 1234 ]
    instance.template = "hi\nmom\n{{#list}} <li>{{item}}</li> {{/gist}}"

    begin
      instance.render
    rescue => e
    end

    assert e.message.include?('Line 3')
  end

  def test_knows_when_its_been_compiled_when_set_with_string
    klass = Class.new(Mustache)

    refute klass.compiled?
    klass.template = 'Hi, {{person}}!'
    assert klass.compiled?
  end

  def test_knows_when_its_been_compiled_at_the_instance_level
    klass = Class.new(Mustache)
    instance = klass.new

    refute instance.compiled?
    instance.template = 'Hi, {{person}}!'
    assert instance.compiled?
  end

  def test_lots_of_staches
    template = "{{{{foo}}}}"

    begin
      Mustache.render(template, :foo => "defunkt")
    rescue => e
    end

    assert e.message.include?("Illegal content in tag")
  end

  def test_liberal_tag_names
    template = "{{first-name}} {{middle_name!}} {{lastName?}}"
    hash = {
      'first-name' => 'chris',
      'middle_name!' => 'j',
      'lastName?' => 'strath'
    }

    assert_equal "chris j strath", Mustache.render(template, hash)
  end

  def test_custom_html_escaping
    view = Class.new(Mustache) do
      def escapeHTML(str)
        "pong"
      end
    end

    assert_equal 'pong', view.render("{{thing}}", :thing => "nothing")
    assert_equal 'nothing', Mustache.render("{{thing}}", :thing => "nothing")
  end

  def test_custom_escaping
    view = Class.new(Mustache) do
      def escape(str)
        JSON.dump(str)
      end
    end

    assert_equal '{ "key": "a\"b" }', view.render('{ "key": {{thing}} }', :thing => 'a"b')
    assert_equal 'nothing', Mustache.render("{{thing}}", :thing => "nothing")
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

  def test_cast_to_hash_in_context
    hashlike = Object.new
    def hashlike.title
    end
    def hashlike.to_hash
      { title: 'title' }
    end

    template = '%%{{title}}%%'

    assert_equal '%%title%%', Mustache.render(template, hashlike)
  end
end
