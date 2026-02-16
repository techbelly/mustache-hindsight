require 'cgi'

require 'mustache/parser'
require 'mustache/generator'

class Mustache
  class Template
    def initialize(source, options = {})
      @source = source
      @options = options
    end

    def render(context)
      compiled = "def render(ctx) #{compile} end"

      instance_eval(compiled, __FILE__, __LINE__ - 1)

      render(context)
    end

    def compile(src = @source)
      Generator.new(@options).compile(tokens(src))
    end
    alias_method :to_s, :compile

    def tokens(src = @source)
      Parser.new(@options).compile(src)
    end

    def sections
      Template.recursor(tokens, []) do |token, section|
        if [:section, :inverted_section].include?(token[1])
          new_section=(section + [token[2][2][0]])
          [ new_token=token[4], new_section, result=new_section.join('.'), stop=false ]
        else
          [ new_token=token, new_section=section, result=nil, stop=false ]
        end
      end.flatten.reject(&:nil?).uniq
    end

    def partials
      Template.recursor(tokens, []) do |token, section|
        if token[1] == :partial
          [ new_token=token, new_section=section, result=token[2], stop=true ]
        else
          [ new_token=token, new_section=section, result=nil, stop=false ]
        end
      end.flatten.reject(&:nil?).uniq
    end

    def self.recursor(toks, section, &block)
      toks.map do |token|
        next unless token.is_a? Array

        if token.first == :mustache
          new_token, new_section, result, stop = yield(token, section)
          [ result ] + ( stop ? [] : recursor(new_token, new_section, &block))
        else
          recursor(token, section, &block)
        end
      end
    end
  end
end
