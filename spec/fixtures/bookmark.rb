module Ardm
  module PropertyFixtures
    class Bookmark < ActiveRecord::Base
      self.table_name = "bookmarks"

      property :id, Serial

      property :title,  String, :length => 255
      property :shared, Boolean
      property :uri,    URI
      property :tags,   Yaml
    end # Bookmark
  end
end
