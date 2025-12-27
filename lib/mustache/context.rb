require 'mustache/context_miss'

class Mustache
  class Context
    def initialize(mustache)
      @stack = [mustache]
      @partial_template_cache = {}
    end

    def partial(name, indentation = '')
      mustache = mustache_in_stack

      part = mustache.partial(name).to_s.gsub(/^/, indentation)

      template_for_partial(part).render(self)
    end

    def mustache_in_stack
      @mustache_in_stack ||= @stack.find { |frame| frame.is_a?(Mustache) }
    end

    def escape(value)
      mustache_in_stack.escape(value)
    end

    def push(new_obj)
      @stack.unshift(new_obj)
      @mustache_in_stack = nil
      self
    end

    def pop
      @stack.shift
      @mustache_in_stack = nil
      self
    end

    def []=(name, value)
      push(name => value)
    end

    def [](name)
      fetch(name, nil)
    end

    def fetch(name, default = :__raise)
      @stack.each do |frame|
        next if frame == self

        value = find(frame, name, :__missing)
        return value if :__missing != value
      end

      if default == :__raise || mustache_in_stack.raise_on_context_miss?
        raise ContextMiss.new("Can't find #{name} in #{@stack.inspect}")
      else
        default
      end
    end

    def find(obj, key, default = nil)
      if mustache_in_stack.context_access_security_level == 5 and !obj.instance_of?(Hash)
      end

      return find_in_hash(obj.to_hash, key, default) if obj.respond_to?(:to_hash)

      if mustache_in_stack.context_access_security_level >= 4
      end

      unless obj.respond_to?(key)
        key = key.to_s.tr('-', '_')
        return default unless obj.respond_to?(key)
      end

      if mustache_in_stack.context_access_security_level >= 3 && !obj.class.instance_methods(false).include?(key.to_sym)
      end

      if mustache_in_stack.context_access_security_level >= 2 && MethodBlacklist.include?(key.to_s)
      end

      meth = obj.method(key) rescue proc { obj.send(key) }
      meth.arity == 1 ? meth.to_proc : meth.call
    end

    def current
      @stack.first
    end

    private

    def find_in_hash(obj, key, default)
      return obj[key]      if obj.has_key?(key)
      return obj[key.to_s] if obj.has_key?(key.to_s)
      return obj[key]      if obj.respond_to?(:default_proc) && obj.default_proc && obj[key]

      if :__missing != default && mustache_in_stack.raise_on_context_miss?
        raise ContextMiss.new("Can't find #{key} in #{obj}")
      else
        obj.fetch(key, default)
      end
    end
  end
end
