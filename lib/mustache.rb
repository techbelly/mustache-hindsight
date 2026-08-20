require 'mustache/enumerable'
require 'mustache/template'
require 'mustache/context'
require 'mustache/settings'
require 'mustache/utils'

class Mustache
  def initialize(options = {})
    @options = options
    
    initialize_settings
  end

  def self.render(*args)
    new.render(*args)
  end

  def render(data = template, ctx = {})
    case data
    when Hash
      ctx = data
    when Symbol
      self.template_name = data
    end

    tpl = case data
    when Hash
      templateify(template)
    when Symbol
      templateify(template)
    else
      templateify(data)
    end

    return tpl.render(context) if ctx == {}

    begin
      context.push(ctx)
      tpl.render(context)
    ensure
      context.pop
    end
  end

  def [](key)
    context[key.to_sym]
  end

  def []=(key, value)
    context[key.to_sym] = value
  end

  def context
    @context ||= Context.new(self)
  end

  def self.render_file(name, context = {})
    render(partial(name), context)
  end

  def render_file(name, context = {})
    self.class.render_file(name, context)
  end

  def self.partial(name)
    self.new.partial(name)
  end

  def partial(name)
    partialpath = template_path.map{|p| "#{p}/#{name}.#{template_extension}" }.find{|pf| File.readable? pf}

    raise RuntimeError.new("Can't find partial #{name}") if not partialpath and raise_on_context_miss?

    partialpath ? File.read(partialpath) : ""
  end

  def escape(value)
    self.escapeHTML(value.to_s)
  end
  
  def escapeHTML(str)
    CGI.escapeHTML(str)
  end

  def compiled?
    (@template && @template.is_a?(Template)) || self.class.compiled?
  end

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

    require file_path.chomp('.rb')
    rescued_const_get(name)
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

  def templateify(obj)
    opts = {:partial_resolver => self.method(:partial)}
    opts.merge!(@options) if @options.is_a?(Hash)
    self.class.templateify(obj, opts)
  end

  def self.inheritable_config_for(attr_name, default)
    superclass.respond_to?(attr_name) ? superclass.send(attr_name) : default
  end
end
