require 'active_support/concern'

module Ardm
  module ActiveRecord
    module StorageNames
      extend ActiveSupport::Concern

      module ClassMethods
        def storage_names
          Ardm::ActiveRecord::StorageNames::Proxy.new(self)
        end
      end

      class Proxy
        def initialize(model)
          @model = model
        end

        def []=(repo, table_name)
          unless repo == :default
            raise ArgumentError, "repositories other than :default not supported."
          end
          @model.table_name = table_name
        end
      end
    end
  end
end
