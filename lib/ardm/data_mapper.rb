require 'ardm/data_mapper/record'

module Ardm
  Record = Ardm::DataMapper::Record
  SaveFailure = ::DataMapper::SaveFailure
  RecordNotFound = ::DataMapper::ObjectNotFoundError
end
