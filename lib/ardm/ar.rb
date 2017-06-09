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
require 'ardm/ar/validations'

module Ardm
  Record           = Ardm::Ar::Record
  Validations      = Ardm::Ar::Validations
  SaveFailureError = ::ActiveRecord::RecordNotSaved
  RecordNotFound   = ::ActiveRecord::RecordNotFound

  def self.define_datamapper_constant!
    require 'ardm/ar/data_mapper_constant'
  end
end

::ActiveRecord::Relation.class_eval do
  include Ardm::Ar::Relation
end

ActiveRecord::Scoping::Named::ClassMethods.class_eval do
  def all(options = {})
    scope_of_all = if current_scope
                     current_scope.clone
                   else
                     default_scoped
                   end
    if options.any?
      scope_of_all.all.all(options)
    else
      scope_of_all
    end
  end
end

# ActiveRecord::ConnectionAdapters::Column.class_eval do
#   def default=(arg)
#     @default = arg
#   end
# end
