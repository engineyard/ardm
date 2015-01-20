require 'ardm'

# only load support libs in active record mode (dm will supply its own libs)
require 'ardm/support/ext/blank'
require 'ardm/support/ext/hash'
require 'ardm/support/ext/object'
require 'ardm/support/ext/string'

require 'ardm/support/ext/module'
require 'ardm/support/ext/array'
require 'ardm/support/ext/try_dup'

require 'ardm/support/mash'
require 'ardm/support/deprecate'
require 'ardm/support/descendant_set'
require 'ardm/support/equalizer'
require 'ardm/support/assertions'
require 'ardm/support/lazy_array'
require 'ardm/support/local_object_space'
require 'ardm/support/hook'
require 'ardm/support/subject'
require 'ardm/support/ordered_set'
require 'ardm/support/subject_set'
require 'ardm/support/descendant_set'

require 'active_record'
require 'active_record/relation'

require 'ardm/ar/record'
require 'ardm/ar/relation'
require 'ardm/ar/data_mapper_constant_proxy'

module Ardm
  Record = Ardm::Ar::Record
  SaveFailureError = ::ActiveRecord::RecordNotSaved
  RecordNotFound = ::ActiveRecord::RecordNotFound

  def self.define_datamapper_constant!
    require 'ardm/ar/data_mapper_constant'
  end
end

::ActiveRecord::Relation.class_eval do
  include Ardm::Ar::Relation
end
