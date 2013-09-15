#require 'active_record'
#
module Ardm
  class Property
    module Rails
    end # module Rails
  end # class Property
end # module Ardm

require 'ardm-property/rails/active_record_class_methods'
require 'ardm-property/rails/active_record_instance_methods'
require 'ardm-property/rails/active_record_finder_methods'

ActiveRecord::Base.extend Ardm::Property::Rails::ActiveRecordClassMethods
#ActiveRecord::Base.extend Ardm::Property::Rails::ActiveRecordFinderMethods
ActiveRecord::Base.extend Ardm::Property::Lookup
ActiveRecord::Base.send :include, Ardm::Property::Rails::ActiveRecordInstanceMethods
#ActiveRecord::QueryMethods.send :include, Ardm::Property::Rails::QueryMethods
#ActiveRecord::Base.extend Ardm::Property::Rails::QueryMethods
ActiveRecord::Relation.send :include, Ardm::Property::Rails::QueryMethods
