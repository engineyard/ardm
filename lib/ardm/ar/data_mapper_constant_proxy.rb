module Ardm
  module Ar
    module DataMapperConstantProxy

      class << self
        extend Forwardable
        def_delegators 'Ardm::Record',
          :finalize,
          :repository,
          :logger,
          :logger=
      end

      module Resource
      end

      ObjectNotFoundError = ::ActiveRecord::RecordNotFound
      SaveFailureError = ::ActiveRecord::RecordNotSaved

      Property = Ardm::Property
      Collection = Ardm::Collection
    end
  end
end
