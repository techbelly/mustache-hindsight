require 'mustache/enumerable'
require 'mustache/template'
require 'mustache/settings'
require 'mustache/utils'

class Mustache
  

  private

  def self.compiled?
    @template.is_a? Template
  end

  def self.underscore(classified = name)
    classified = superclass.name if classified.to_s.empty?

    Mustache::Utils::String.new(classified).underscore(view_namespace)
  end

  def self.templateify(obj, options = {})
    obj.is_a?(Template) ? obj : Template.new(obj, options)
  end

  def self.inheritable_config_for(attr_name, default)
    superclass.respond_to?(attr_name) ? superclass.send(attr_name) : default
  end
end
