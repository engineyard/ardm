require 'ardm'

require 'dm-core'
require 'ardm/dm/record'
require 'ardm/dm/collection'

module Ardm
  Record           = Ardm::Dm::Record
  SaveFailureError = ::DataMapper::SaveFailureError
  RecordNotFound   = ::DataMapper::ObjectNotFoundError
  Property         = ::DataMapper::Property
  Collection       = ::DataMapper::Collection
end
