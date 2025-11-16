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
    end

    def find(obj, key, default = nil)
      if mustache_in_stack.context_access_security_level == 5 and !obj.instance_of?(Hash)
      end

      return find_in_hash(obj.to_hash, key, default) if obj.respond_to?(:to_hash)
    end

    private

    def find_in_hash(obj, key, default)
      return obj[key]      if obj.has_key?(key)
    end
  end
end
