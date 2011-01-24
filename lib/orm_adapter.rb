require 'orm_adapter/base'
require 'orm_adapter/to_adapter'
require 'orm_adapter/version'

module OrmAdapter
  # A collection of registered adapters
  def self.adapters
    @@adapters ||= []
  end

  # All model classes from all registered adapters
  def self.model_classes
    self.adapters.map { |a| a.model_classes }.flatten
  end
end


require 'orm_adapter/adapters/mongo_mapper' 

