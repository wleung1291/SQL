require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :class_name => name.to_s.camelcase,
      :primary_key => :id,
      :foreign_key => "#{name}_id".to_sym
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :primary_key => :id,
      :foreign_key => "#{self_class_name.underscore}_id".to_sym,
      :class_name => name.to_s.singularize.camelcase
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable
  # Phase IIIb
  # This method should take in the association name and an options hash
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
  
    # create a new method to access the association
    define_method(name) do
      options = self.class.assoc_options[name] 
      # get the value of the foreign key
      fkey_val = self.send(options.foreign_key)
      #  get the target model class
      target_model_class = options.model_class
      # select those models where the primary_key column is equal to the 
      # foreign key value
      target = target_model_class.where(options.primary_key => fkey_val).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      fkey_val = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => fkey_val)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
