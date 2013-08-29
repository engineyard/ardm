module Ardm
  module PropertyFixtures
    class SoftwarePackage < ActiveRecord::Base
      self.table_name = "softwark_packages"

      property :id, Serial
      property :node_number, Integer, :index => true

      property :source_path,      FilePath
      property :destination_path, FilePath

      property :product,     String
      property :version,     String
      property :released_at, DateTime

      property :security_update,  Boolean

      property :installed_at,     DateTime
      property :installed_by,     String
    end # SoftwarePackage
  end # PropertyFixtures
end # Ardm
