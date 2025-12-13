require_relative 'helper'
require 'json'

class MustacheTest < Minitest::Test
  def test_single_line_sections
    html = %(<p class="flash-notice" {{# no_flash }}style="display: none;"{{/ no_flash }}>)

    instance = Mustache.new
    instance.template = html
    instance[:no_flash] = true
    assert_equal %Q'<p class="flash-notice" style="display: none;">', instance.render
  end

  def test_sassy_single_line_sections
    instance = Mustache.new
    instance[:full_time] = true
    instance.template = "\n {{#full_time}}full time{{/full_time}}\n"

    assert_equal "\n full time\n", instance.render
  end

  def test_sassier_single_line_sections
    instance = Mustache.new
    instance.template = "\t{{#list}}\r\n\t{{/list}}"

    assert_equal "", instance.render
  end

  def test_padding_before_section
    instance = Mustache.new
    instance.template = "\t{{#list}}a{{/list}}"

    assert_equal "\taa", instance.render(:list => [1, 2])
  end

  def test_padding_before_section_on_eos
    instance = Mustache.new
    instance.template = "{{#list}}\n\t{{/list}}"

    assert_equal "", instance.render(:list => [1, 2])
  end

  def test_two_line_sections
    html = %(<p class="flash-notice" {{# no_flash }}style="display: none;"\n{{/ no_flash }}>)

    instance = Mustache.new
    instance.template = html
    instance[:no_flash] = true
    assert_equal %Q'<p class="flash-notice" style="display: none;"\n>', instance.render
  end

  def test_multi_line_sections_preserve_trailing_newline
    view = Mustache.new
    view.template = <<template
{{#something}}
yay
{{/something}}
Howday.
template

    view[:something] = true
    assert_equal <<-rendered, view.render
yay
Howday.
rendered
  end

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

  def test_doesnt_execute_what_it_doesnt_need_to
    instance = Mustache.new
    instance[:show] = false
    instance.instance_eval do
      def die
      end
    end
    instance.template = '{{#show}} <li>{{die}}</li> {{/show}} yay'

    assert_equal " yay", instance.render
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

  def test_enumerable_sections_accept_a_hash_as_a_context
    instance = Mustache.new
    instance[:list] = { :item => 1234 }
    instance.template = '{{#list}} <li>{{item}}</li> {{/list}}'

    assert_equal ' <li>1234</li> ', instance.render
  end

  def test_enumerable_sections_accept_a_string_keyed_hash_as_a_context
    instance = Mustache.new
    instance[:list] = { 'item' => 1234 }
    instance.template = '{{#list}} <li>{{item}}</li> {{/list}}'

    assert_equal ' <li>1234</li> ', instance.render
  end

  def test_not_found_in_context_renders_empty_string
    instance = Mustache.new
    instance.template = '{{#list}} <li>{{item}}</li> {{/list}}'

    assert_equal '', instance.render
  end

  def test_not_found_in_nested_context_renders_empty_string
    instance = Mustache.new
    instance[:list] = { :item => 1234 }
    instance.template = '{{#list}} <li>{{prefix}}{{item}}</li> {{/list}}'

    assert_equal ' <li>1234</li> ', instance.render
  end

  def test_found_in_nested_context_when_asked_to_raise
    instance = Mustache.new
    instance.raise_on_context_miss = true

    instance[:item] = { :list => [ { :value => 1235, :deep_list => [{:x => 'y'}]}] }

    instance.template = '{{#item.list}}{{#deep_list}}{{value}}{{/deep_list}}{{/item.list}}'
    assert_equal '1235', instance.render
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

  def test_sections_returning_lambdas_get_called_dynamically_with_text
    view = Mustache.new
    view.template       = '{{name}}'
    view[:name]         = lambda { '{{dynamic_name}}' }
    view[:dynamic_name] = 'Chris'

    assert_equal "Chris", view.render.chomp
  end

  def test_sections_returning_lambdas_get_not_called_dynamically_with_text_if_static
    view = Mustache.new :static_lambdas => true
    view.template       = '{{name}}'
    view[:name]         = lambda { '{{dynamic_name}}' }
    view[:dynamic_name] = 'Chris'

    assert_equal "{{dynamic_name}}", view.render.chomp
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

  def test_nested_sections_same_names
    template = <<template
{{#items}}
start
{{#items}}
{{a}}
{{/items}}
end
{{/items}}
template

    data = {
      "items" => [
        { "items" => [ {"a" => 1}, {"a" => 2}, {"a" => 3} ] },
        { "items" => [ {"a" => 4}, {"a" => 5}, {"a" => 6} ] },
        { "items" => [ {"a" => 7}, {"a" => 8}, {"a" => 9} ] }
      ]
    }

    assert_equal <<expected, Mustache.render(template, data)
start
1
2
3
end
start
4
5
6
end
start
7
8
9
end
expected
  end

  def test_id_with_nested_context
    html = %(<div>{{id}}</div>\n<div>{{# has_a? }}{{id}}{{/ has_a? }}</div>\n<div>{{# has_b? }}{{id}}{{/ has_b? }}</div>\n)

    instance = Mustache.new
    instance.template = html
    instance[:id] = 3
    instance[:has_a?] = true
    instance[:has_b?] = true
    assert_equal <<-rendered, instance.render
<div>3</div>
<div>3</div>
<div>3</div>
rendered
  end

  def test_indentation
    view = Mustache.new
    view[:name] = 'indent'
    view[:text] = 'puts :indented!'
    view.template = <<template
def {{name}}
  {{text}}
end
template

  assert_equal <<template, view.render
def indent
  puts :indented!
end
template
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

  def test_implicit_iterator
    view = Mustache.new
    view.template = "{{#people}}* {{.}}\n{{/people}}"
    view[:people] = %w( Chris Mark Scott )

    assert_equal <<text, view.render
* Chris
* Mark
* Scott
text
  end

  def test_unescaped_implicit_iterator
    view = Mustache.new
    view.template = "{{#people}}* {{{.}}}\n{{/people}}"
    view[:people] = %w( Chris Mark Scott )

    assert_equal <<text, view.render
* Chris
* Mark
* Scott
text
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

  def test_hash_default_proc
    template = <<template
{{greetings.Peter}}
{{greetings.Paul}}
{{greetings.Mary}}
template
    data = {
      'greetings' => Hash.new { |hash, key| hash[key] = "Hello, #{key}!" }
    }

    assert_equal <<expected, Mustache.render(template, data)
Hello, Peter!
Hello, Paul!
Hello, Mary!
expected
  end

  def test_indentation_again
    template = <<template
SELECT
  {{#cols}}
    {{name}},
  {{/cols}}
FROM
  DUMMY1
template

    view = Mustache.new
    view[:cols] = [{:name => 'Name'}, {:name => 'Age'}, {:name => 'Weight'}]
    view.template = template

    assert_equal <<template, view.render
SELECT
    Name,
    Age,
    Weight,
FROM
  DUMMY1
template
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

  def test_variable_with_at_name
    instance = Mustache.new
    instance.template = "\t{{#list@home}}a{{/list@home}}"

    assert_equal "\taa", instance.render(:"list@home" => [1, 2])
  end
end
