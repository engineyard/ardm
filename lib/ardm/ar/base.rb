require 'active_support/concern'

require 'ardm/ar/associations'
require 'ardm/ar/dirty'
require 'ardm/ar/finalize'
require 'ardm/ar/hooks'
require 'ardm/ar/is'
require 'ardm/ar/inheritance'
require 'ardm/ar/persistence'
require 'ardm/ar/property'
require 'ardm/ar/query'
require 'ardm/ar/repository'
require 'ardm/ar/storage_names'
require 'ardm/ar/validations'

module Ardm
  module Ar
    # Include all the Ardm modules.
    #
    # You can use this directly if you want your own abstract base class.
    #
    #   require 'ardm/active_record/base'
    #
    #   class MyRecord < ActiveRecord::Base
    #     include Ardm::Ar::Base
    #   end
    #
    # Or Ardm::ActiveRecord::Base is built in to Ardm::Record
    #
    #   require 'ardm/active_record/record'
    #
    #   class MyRecord < Ardm::Record
    #     # already included
    #   end
    #
    module Base
      extend ActiveSupport::Concern

      include Ardm::Ar::Associations
      include Ardm::Ar::Finalize
      include Ardm::Ar::Hooks
      include Ardm::Ar::Dirty
      include Ardm::Ar::Is
      include Ardm::Ar::Inheritance
      include Ardm::Ar::Persistence
      include Ardm::Ar::Property
      include Ardm::Ar::Query
      include Ardm::Ar::Repository
      include Ardm::Ar::StorageNames
      include Ardm::Ar::Validations
    end
  end
end
