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
      <<-compiled
        ctx[#{initial.inspect}]
      compiled
    end

    def ev(s)
      "#\{#{s}}"
    end

    def str(s)
      s.inspect[1..-2]
    end
  end
end
