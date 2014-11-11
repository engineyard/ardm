require 'active_support/concern'

require 'ardm/active_record/associations'
require 'ardm/active_record/dirty'
require 'ardm/active_record/finalize'
require 'ardm/active_record/hooks'
require 'ardm/active_record/is'
require 'ardm/active_record/inheritance'
require 'ardm/active_record/persistence'
require 'ardm/active_record/property'
require 'ardm/active_record/query'
require 'ardm/active_record/repository'
require 'ardm/active_record/storage_names'
require 'ardm/active_record/validations'

module Ardm
  module ActiveRecord
    # Include all the Ardm modules.
    #
    # You can use this directly if you want your own abstract base class.
    #
    #   require 'ardm/active_record/base'
    #
    #   class MyRecord < ActiveRecord::Base
    #     include Ardm::ActiveRecord::Base
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

      include Ardm::ActiveRecord::Associations
      include Ardm::ActiveRecord::Finalize
      include Ardm::ActiveRecord::Hooks
      include Ardm::ActiveRecord::Dirty
      include Ardm::ActiveRecord::Is
      include Ardm::ActiveRecord::Inheritance
      include Ardm::ActiveRecord::Persistence
      include Ardm::ActiveRecord::Property
      include Ardm::ActiveRecord::Query
      include Ardm::ActiveRecord::Repository
      include Ardm::ActiveRecord::StorageNames
      include Ardm::ActiveRecord::Validations
    end
  end
end
