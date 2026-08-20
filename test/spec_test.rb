require 'mustache'
require 'tmpdir'
require 'yaml'
require 'minitest/autorun'

YAML.add_domain_type(nil, 'code') { |_, val| eval(val['ruby']) }

class MustacheSpec < Minitest::Test
  def setup
    @partials = File.join(File.dirname(__FILE__), 'partials')
    Dir.mkdir(@partials)

    @Mustache = Class.new(Mustache)
    @Mustache.template_path = @partials
  end

  def teardown
    Dir[File.join(@partials, '*')].each { |file| File.delete(file) }
    Dir.rmdir(@partials)
  end

  def setup_partials(test)
    (test['partials'] || {}).each do |name, content|
      File.open(File.join(@partials, "#{name}.mustache"), 'w') do |f|
        f.print(content)
      end
    end
  end

  def assert_mustache_spec(test)
    actual = @Mustache.render(test['template'], test['data'])

    assert_equal test['expected'], actual, "" <<
      "#{ test['desc'] }\n" <<
      "Data: #{ test['data'].inspect }\n" <<
      "Template: #{ test['template'].inspect }\n" <<
      "Partials: #{ (test['partials'] || {}).inspect }\n"
  end

  def test_noop; assert(true); end
end

spec_files = File.join(File.dirname(__FILE__), '..', 'ext', 'spec', 'specs', '*.yml')
Dir[spec_files].each do |file|
  spec = YAML.load_file(file)

  klass_name = "Test" + File.basename(file, ".yml").sub(/~/, '').capitalize
  instance_eval "class ::#{klass_name} < MustacheSpec; end"
  test_suite = Kernel.const_get(klass_name)

  test_suite.class_eval do
    spec['tests'].each do |test|
      define_method :"test_spec - #{test['name']}" do
        setup_partials(test)
        assert_mustache_spec(test)
      end
    end
  end
end
