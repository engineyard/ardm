require 'ardm'
require 'ardm/dm/record'

module Ardm
  Record = Ardm::Dm::Record
  SaveFailureError = ::Dm::SaveFailureError
  RecordNotFound = ::Dm::ObjectNotFoundError
  Property = ::Dm::Property
  Collection = ::Dm::Collection
end
