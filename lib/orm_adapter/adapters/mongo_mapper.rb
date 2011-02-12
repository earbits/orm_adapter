require 'mongo_mapper'

module MongoMapperToOrmAdapter
   extend ActiveSupport::Concern
    module ClassMethods
      include OrmAdapter::ToAdapter
    end
end


module MongoMapper::Document
    
    class OrmAdapter < ::OrmAdapter::Base
      # Do not consider these to be part of the class list
      def self.except_classes
        @@except_classes ||= []
      end

      # Gets a list of the available models for this adapter
      def self.model_classes
         ObjectSpace.each_object(Class).to_a.select {|klass| klass.ancestors.include? MongoMapper::Document}
      end

      # get a list of column names for a given class
      def column_names
        klass.keys.keys
      end

      # @see OrmAdapter::Base#get!
      def get!(id)
        klass.find!(wrap_key(id))
      end

      # @see OrmAdapter::Base#get
      def get(id)
        klass.find(wrap_key(id))
      end

      # @see OrmAdapter::Base#find_first
      def find_first(options)
        conditions, order = extract_conditions_and_order!(options)
        klass.where( conditions_to_fields(conditions)).sort(order).first
      end

      # @see OrmAdapter::Base#find_all
      def find_all(options)
        conditions, order = extract_conditions_and_order!(options)
        klass.where( conditions_to_fields(conditions)).sort(order).all
      end

      # @see OrmAdapter::Base#create!
      def create!(attributes)
        klass.create!(attributes)
      end
  
    protected
    
    

      # converts and documents to ids
      def conditions_to_fields(conditions)
        conditions.inject({}) do |fields, (key, value)|
          if value.is_a?(MongoMapper::Document) && klass.keys.keys.include?("#{key}_id")
            fields.merge("#{key}_id" => value.id)
          else
            fields.merge(key => value)
          end
        end
      end
    end
end

#MongoMapper::Document.append_inclusions(OrmAdapter::ToAdapter)
#MongoMapper::Document.append_inclusions(MongoMapperOrmAdapter)
