require 'awsm/resource'

module Ardm
  module DataMapper
    module Record
      extend ActiveSupport::Concern

      NotFound = DataMapper::ObjectNotFoundError

      module ClassMethods
        def inherited(base)
          base.send(:include, DataMapper::Resource)
          base.send(:include, Awsm::Resource)
          #base.send(:extend, DataMapper::CollectionRaise)

          unless %w[Alert Association Nonce Account::Cancellation::Handler].include?(base.name)
            base.timestamps :at
          end
        end

        extend Forwardable
        def datamapper() DataMapper end
        def_delegators :datamapper, :repository, :finalize, :logger, :logger=

          def execute_sql(sql)
            DataMapper.repository.adapter.execute(sql)
          end

        def alias_attribute(new, old)
          alias_method new, old
        end

        def attr_accessible(*attrs)
        end

        def abstract_class=(val)
        end
      end
    end
  end
end
