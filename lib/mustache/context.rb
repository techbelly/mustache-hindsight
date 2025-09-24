require 'mustache/context_miss'

class Mustache
  class Context
    def partial(name, indentation = '')
      mustache = mustache_in_stack

      part = mustache.partial(name).to_s.gsub(/^/, indentation)

      template_for_partial(part).render(self)
    end

    private
  end
end
