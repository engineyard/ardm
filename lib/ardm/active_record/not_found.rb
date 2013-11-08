require 'ardm/active_record/record'

module Ardm
  class Record < ::ActiveRecord::Base
    NotFound = ::ActiveRecord::RecordNotFound
  end
end
