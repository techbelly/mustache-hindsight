require 'mustache/enumerable'
require 'mustache/template'
require 'mustache/settings'

class Mustache
  

  private

  def self.templateify(obj, options = {})
    obj.is_a?(Template) ? obj : Template.new(obj, options)
  end

  def self.inheritable_config_for(attr_name, default)
    superclass.respond_to?(attr_name) ? superclass.send(attr_name) : default
  end
end
