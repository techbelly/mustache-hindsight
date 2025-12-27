class Mustache
  class ContextMiss < RuntimeError;  end
  class Context
  end

  MethodBlacklist = ["allocate", "attached_object", "superclass", "subclasses", "new", "autoload?", "autoload",
  "included_modules", "include?", "set_temporary_name", "ancestors", "attr", "attr_reader", "attr_writer",
  "attr_accessor", "public_instance_method", "instance_methods", "public_instance_methods",
  "protected_instance_methods", "private_instance_methods", "undefined_instance_methods", "freeze", "const_get",
  "constants", "const_missing", "const_defined?", "const_set", "const_source_location", "remove_class_variable",
  "class_variable_get", "class_variables", "private_constant", "class_variable_set", "class_variable_defined?",
  "public_constant", "include", "deprecate_constant", "singleton_class?", "prepend", "refinements", "define_method",
  "module_exec", "class_exec", "module_eval", "class_eval", "remove_method", "undef_method", "alias_method",
  "method_defined?", "public_method_defined?", "private_method_defined?", "protected_method_defined?",
  "public_class_method", "private_class_method", "instance_method", "singleton_class", "dup", "itself", "methods",
  "singleton_methods", "protected_methods", "private_methods", "public_methods", "instance_variables",
  "instance_variable_get", "instance_variable_set", "instance_variable_defined?", "remove_instance_variable",
  "instance_of?", "kind_of?", "is_a?", "display", "public_send", "extend", "clone", "class", "frozen?", "tap",
  "then", "yield_self", "respond_to?", "method", "public_method", "singleton_method", "define_singleton_method",
  "hash", "object_id", "send", "enum_for", "__send__", "instance_eval", "instance_exec", "__id__"]
end
