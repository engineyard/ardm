require 'active_record/relation/predicate_builder' # force it to load

require 'ardm/active_record/predicate_builder/relation_handler'
require 'ardm/active_record/predicate_builder/array_handler'

if ::ActiveRecord::PredicateBuilder.respond_to? :expand
  require 'ardm/active_record/predicate_builder/rails4'
  ::ActiveRecord::PredicateBuilder.send(:include, Ardm::ActiveRecord::PredicateBuilder::Rails4)
else
  require 'ardm/active_record/predicate_builder/rails3'
  ::ActiveRecord::PredicateBuilder.send(:include, Ardm::ActiveRecord::PredicateBuilder::Rails3)
end

::ActiveRecord::PredicateBuilder.class_eval do
  # calls super instead of calling the method on the class
  class << self
    remove_method :build_from_hash
  end
end
