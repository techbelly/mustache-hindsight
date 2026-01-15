class Mustache
  class Generator
    def initialize(options = {})
      @options = options
      @option_static_lambdas = options[:static_lambdas] == true
    end

    def compile(exp)
      "\"#{compile!(exp)}\""
    end

    private

    def compile!(exp)
      case exp.first
      when :multi
        exp[1..-1].reduce("".dup) { |sum, e| sum << compile!(e) }
      when :static
        str(exp[1])
      when :mustache
        send("on_#{exp[1]}", *exp[2..-1])
      end
    end

    def on_section(name, offset, content, raw, delims)
      code = compile(content)

      proc_handling = if @option_static_lambdas
      else
        <<-compiled
          t = Mustache::Template.new(v.call(#{raw.inspect}).to_s)
          def t.tokens(src=@source)
            p = Mustache::Parser.new
            p.otag, p.ctag = #{delims.inspect}
            p.compile(src)
          end
          t.render(ctx.dup)
        compiled
      end

      ev(<<-compiled)
      case v = #{compile!(name)}
      when NilClass, FalseClass
      when TrueClass
        #{code}
      when Proc
        #{proc_handling}
      when Array, Enumerator, Mustache::Enumerable
        v.map { |_| ctx.push(_); r = #{code}; ctx.pop; r }.join
      else
        ctx.push(v); r = #{code}; ctx.pop; r
      end
      compiled
    end

    def on_partial(name, offset, indentation)
      ev("ctx.partial(#{name.to_sym.inspect}, #{indentation.inspect})")
    end

    def on_utag(name, offset)
      ev(<<-compiled)
        v = #{compile!(name)}
        if v.is_a?(Proc)
          v = #{@option_static_lambdas ? 'v.call' : 'Mustache::Template.new(v.call.to_s).render(ctx.dup)'}
        end
        v.to_s
      compiled
    end

    def on_etag(name, offset)
      ev(<<-compiled)
        v = #{compile!(name)}
        if v.is_a?(Proc)
          v = #{@option_static_lambdas ? 'v.call' : 'Mustache::Template.new(v.call.to_s).render(ctx.dup)'}
        end
        ctx.escape(v)
      compiled
    end

    def on_fetch(names)
      return "ctx.current" if names.empty?

      names = names.map { |n| n.to_sym }

      initial, *rest = names
      if rest.any?
        <<-compiled
          #{rest.inspect}.reduce(ctx[#{initial.inspect}]) { |value, key| value && ctx.find(value, key) }
        compiled
      else
        <<-compiled
          ctx[#{initial.inspect}]
        compiled
      end
    end

    def ev(s)
      "#\{#{s}}"
    end

    def str(s)
      s.inspect[1..-2]
    end
  end
end
