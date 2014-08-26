require 'ardm/data_mapper/record'

module Ardm
  Record = Ardm::DataMapper::Record
  SaveFailureError = ::DataMapper::SaveFailureError
  RecordNotFound = ::DataMapper::ObjectNotFoundError
  Property = ::DataMapper::Property
  Collection = ::DataMapper::Collection
end
