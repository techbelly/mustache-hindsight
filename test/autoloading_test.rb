require_relative 'helper'

module TestViews; end
class AutoloadingTest < Minitest::Test
  def setup
    Mustache.view_path = File.dirname(__FILE__) + '/fixtures'
  end

  def teardown
    Mustache.view_namespace = Object
  end

  def test_autoload
    klass = Mustache.view_class(:Comments)
    assert_equal Comments, klass
  end

  def test_autoload_lowercase
    klass = Mustache.view_class(:comments)
    assert_equal Comments, klass
  end

  def test_autoload_nil
    klass = Mustache.view_class(nil)
    assert_equal Mustache, klass
  end

  def test_autoload_empty_string
    klass = Mustache.view_class('')
    assert_equal Mustache, klass
  end

  def test_folder_autoload
    assert_equal TestViews::Namespaced, Mustache.view_class('test_views/namespaced')
  end

  def test_bad_constant_name
    assert_equal Mustache, Mustache.view_class(404)
  end
end
