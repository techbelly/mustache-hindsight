require_relative 'helper'

class AutoloadingTest < Minitest::Test
  def setup
    Mustache.view_path = File.dirname(__FILE__) + '/fixtures'
  end

  def teardown
    Mustache.view_namespace = Object
  end

  def test_autoload_nil
    klass = Mustache.view_class(nil)
    assert_equal Mustache, klass
  end

  def test_autoload_empty_string
    klass = Mustache.view_class('')
    assert_equal Mustache, klass
  end
end
