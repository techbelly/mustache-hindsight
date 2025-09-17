require 'mustache'

module TestViews
  class Namespaced < Mustache
    self.path = File.dirname(__FILE__)

    def title
      "Dragon < Tiger"
    end
  end

  class NamespacedWithPartial < Mustache
    self.path = File.dirname(__FILE__)
    self.template = "My opinion: {{>inner_partial}}"

    def title
      "Victory"
    end
  end
end
