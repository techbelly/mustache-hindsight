require 'mustache/enumerable'
require 'mustache/template'
require 'mustache/settings'
require 'mustache/utils'

class Mustache
  

  private

  def self.view_class(name)
    name = classify(name.to_s)

    return Mustache if name.to_s.empty?

    name = "#{view_namespace}::#{name}"
    const = rescued_const_get(name)

    return const if const

    const_from_file(name)
  end

  def self.rescued_const_get name
    const_get(name, true) || Mustache
  rescue NameError
    nil
  end

  def self.const_from_file name
    file_name = underscore(name)
    file_path = "#{view_path}/#{file_name}.rb"

    return Mustache unless File.exist?(file_path)
  end

  def self.compiled?
    @template.is_a? Template
  end

  def self.classify(underscored)
    Mustache::Utils::String.new(underscored).classify
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
