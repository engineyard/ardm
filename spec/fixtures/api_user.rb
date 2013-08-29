module Ardm
  module PropertyFixtures
    class APIUser < ActiveRecord::Base
      self.table_name = "api_users"

      property :id, Serial
      property :name, String
      property :api_key, APIKey
    end
  end
end
