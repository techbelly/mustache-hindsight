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

  def test_raw_content_and_whitespace
    lexer = Mustache::Parser.new
    tokens = lexer.compile("{{#list}}\t{{/list}}")

    expected = [:multi,
      [:mustache,
        :section,
        [:mustache, :fetch, ["list"]],
        [1, 6],
        [:multi, [:static, "\t"]],
        "\t",
        %w[{{ }}]]]

    assert_equal expected, tokens
  end

  def test_unclosed_section
    lexer = Mustache::Parser.new
    exception = assert_raises Mustache::Parser::SyntaxError do
      lexer.compile("{{#list}}")
    end

    expected = <<-EOF
Unclosed section "list"
  Line 1
    {{#list}}
          ^
EOF

    assert_equal expected, exception.message
  end

  def test_closing_unopened
    lexer = Mustache::Parser.new
    exception = assert_raises Mustache::Parser::SyntaxError do
      lexer.compile("{{/list}}")
    end

    expected = <<-EOF
Closing unopened "list"
  Line 1
    {{/list}}
          ^
EOF

    assert_equal expected, exception.message
  end

  def test_unclosed_tag
    lexer = Mustache::Parser.new
    exception = assert_raises Mustache::Parser::SyntaxError do
      lexer.compile("{{list")
    end

    expected = <<-EOF
Unclosed tag
  Line 1
    {{list
         ^
EOF

    assert_equal expected, exception.message
  end

  def test_illegal_content
    lexer = Mustache::Parser.new
    exception = assert_raises Mustache::Parser::SyntaxError do
      lexer.compile("{{")
    end

    expected = <<-EOF
Illegal content in tag
  Line 1
    {{
     ^
EOF

    assert_equal expected, exception.message
  end
end
