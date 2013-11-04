#require 'active_record'
#
module Ardm
  class Property
    module Rails
    end
  end
end

require 'ardm-property/rails/active_record_class_methods'
require 'ardm-property/rails/active_record_instance_methods'
require 'ardm-property/rails/active_record_finder_methods'

ActiveRecord::Base.extend Ardm::Property::Rails::ActiveRecordClassMethods
ActiveRecord::Base.extend Ardm::Property::Lookup
ActiveRecord::Base.send :include, Ardm::Property::Rails::ActiveRecordInstanceMethods
