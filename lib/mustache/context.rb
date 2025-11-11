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

    private
  end
end
