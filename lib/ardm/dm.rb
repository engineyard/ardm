require 'ardm'

require 'dm-core'
require 'ardm/dm/record'
require 'ardm/dm/collection'

module Ardm
  Record           = Ardm::Dm::Record
  begin
    Validations      = ::DataMapper::Validations
  rescue NameError
    # DataMapper::Validations might not be included.
  end

  SaveFailureError = ::DataMapper::SaveFailureError
  RecordNotFound   = ::DataMapper::ObjectNotFoundError
  Property         = ::DataMapper::Property
  Collection       = ::DataMapper::Collection
end
