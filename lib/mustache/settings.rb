class Mustache
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

  def self.template_extension=(template_extension)
    @template_extension = template_extension
    @template = nil
  end

  def self.template=(template)
    @template = templateify(template)
  end
end
