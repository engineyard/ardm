require 'active_record/relation/predicate_builder' # force it to load

require 'ardm/ar/predicate_builder/relation_handler'
require 'ardm/ar/predicate_builder/array_handler'

if ::ActiveRecord::PredicateBuilder.respond_to? :expand
  require 'ardm/ar/predicate_builder/rails4'
  ::ActiveRecord::PredicateBuilder.send(:include, Ardm::Ar::PredicateBuilder::Rails4)
else
  require 'ardm/ar/predicate_builder/rails3'
  ::ActiveRecord::PredicateBuilder.send(:include, Ardm::Ar::PredicateBuilder::Rails3)
end

::ActiveRecord::PredicateBuilder.class_eval do
  # calls super instead of calling the method on the class
  class << self
    remove_method :build_from_hash
  end
end
