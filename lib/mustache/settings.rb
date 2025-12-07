class Mustache
  def initialize_settings
    @template = nil
    @template_path = nil
    @template_extension = nil
    @template_name = nil
    @template_file = nil
    @raise_on_context_miss = nil
    @context_access_security_level = 2
  end

  def self.initialize_settings
    @template = nil
    @template_path = nil
    @template_extension = nil
    @template_name = nil
    @template_file = nil
    @raise_on_context_miss = nil
    @context_access_security_level = 2
  end

  initialize_settings

  def self.inherited(subclass)
    subclass.initialize_settings
  end

  def self.setup_path path
    path = path.split(File::PATH_SEPARATOR) if path.is_a? String
    path.map{|p| File.expand_path(p)}
  end

  def self.template_path
    @template_path ||= setup_path(inheritable_config_for(:template_path, '.'))
  end

  def self.template_path=(path)
    @template_path = setup_path(path)
    @template = nil
  end

  def template_path
    @template_path ||= self.class.template_path
  end

  alias_method :path, :template_path

  class << self
    alias_method :path, :template_path
    alias_method :path=, :template_path=
  end

  def self.template_extension
    @template_extension ||= inheritable_config_for :template_extension, 'mustache'
  end

  def self.template_extension=(template_extension)
    @template_extension = template_extension
    @template = nil
  end

  def template_extension
    @template_extension ||= self.class.template_extension
  end

  def self.template=(template)
    @template = templateify(template)
  end

  def template
    return @template if @template
  end

  def template=(template)
    @template = templateify(template)
  end

  def raise_on_context_miss=(boolean)
    @raise_on_context_miss = boolean
  end

  def self.context_access_security_level
    @context_access_security_level
  end

  def context_access_security_level
    self.class.context_access_security_level || @context_access_security_level
  end

  def self.view_namespace
    @view_namespace ||= inheritable_config_for(:view_namespace, Object)
  end

  def self.view_namespace=(namespace)
    @view_namespace = namespace
  end

  def self.view_path
    @view_path ||= inheritable_config_for(:view_path, '.')
  end

  def self.view_path=(path)
    @view_path = path
  end
end
