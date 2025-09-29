require_relative 'helper'

class ParserTest < Minitest::Test
  def test_parser_extension
    parser = Mustache::Parser.new
    parser.instance_variable_set :@result, 'zomg'
    Mustache::Parser.add_type(:'@', :'$') do |*args|
      [:mustache, :at_sign, @result, *args]
    end
    assert_match Mustache::Parser.valid_types, '@'
    assert_match Mustache::Parser.valid_types, '$'
    assert_equal [:mustache, :at_sign, 'zomg', 1, 2, 3],
                 parser.send('scan_tag_@', 1, 2, 3)
    assert_equal [:mustache, :at_sign, 'zomg', 1, 2, 3],
                 parser.send('scan_tag_$', 1, 2, 3)
  end
end
