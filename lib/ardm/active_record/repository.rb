require 'active_support/concern'

module Ardm
  module ActiveRecord
    module Repository
      extend ActiveSupport::Concern

      def repository(name=nil)
        self.class.repository
      end

      module ClassMethods
        def repository(name=nil)
          if name && name != :default
            raise Ardm::NotImplemented, "Alternate repository names not supported"
          end

          if block_given?
            yield
          else
            Ardm::ActiveRecord::Repository::Proxy.new self
          end
        end
      end

      class Proxy
        def initialize(model)
          @model = model
        end

        def adapter
          self
        end

        def select(*args)
          array_of_hashes = @model.connection.select_all(@model.send(:sanitize_sql_array, args))
          array_of_hashes.map { |h| Hashie::Mash.new(h) }
        end
      end
    end
  end
end
