require_relative 'helper'

class MustacheTest < Minitest::Test
  def test_default_path
    assert_instance_of Array, Mustache.template_path
    assert_equal 1, Mustache.template_path.size
    assert_includes Mustache.template_path, Dir.pwd
  end

  def test_set_multiple_paths
    old_path = Mustache.template_path
    Mustache.template_path = "this#{File::PATH_SEPARATOR}that"
    assert_instance_of Array, Mustache.template_path
    assert_equal 2, Mustache.template_path.size
    Mustache.template_path = old_path
  end
end
