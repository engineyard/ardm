module Ardm
  module PropertyFixtures
    class Article < ActiveRecord::Base
      self.table_name = "articles"

      property :id,         Serial

      property :title,      String, :length => 255
      property :body,       Text

      property :created_at,   DateTime
      property :updated_at,   DateTime
      property :published_at, DateTime

      property :slug, Slug

      before_validation do
        self.slug = self.title
      end
    end # Article
  end
end
