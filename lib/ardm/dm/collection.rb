module Ardm::Dm
  module RelationChain
    extend ActiveSupport::Concern

    included do
      alias_method :old_delegate_to_relationship, :delegate_to_relationship
    end

    def delegate_to_relationship(relationship, query = nil)
      Ardm::Deprecation.warn("Relation chain #{model.name}.#{relationship.name}")
      old_delegate_to_relationship(relationship, query)
    end

    def includes(*)
      self
    end

    def references(*)
      self
    end
  end
end

DataMapper::Collection.class_eval do
  include Ardm::Dm::RelationChain
end

