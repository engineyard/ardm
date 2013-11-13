require 'awsm/resource'

module Ardm
  module DataMapper
    module Record
      extend ActiveSupport::Concern

      module ClassMethods
        extend Forwardable

        def inherited(base)
          base.send(:include, DataMapper::Resource)
          #base.send(:extend, DataMapper::CollectionRaise)

          unless %w[Alert Association Nonce Account::Cancellation::Handler].include?(base.name)
            base.timestamps :at
          end
        end

        def_delegators :datamapper, :repository, :finalize, :logger, :logger=
        def datamapper() DataMapper end

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
