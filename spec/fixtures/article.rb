module Ardm
  module Fixtures
    class Article < Ardm::Record
      self.table_name = "articles"

      property :id,         Serial

      property :title,      String, :length => 255
      property :body,       Text

      property :created_at,   DateTime
      property :updated_at,   DateTime
      property :published_at, DateTime

      property :slug, Slug

      timestamps :at

      before(:valid?) do
        self.slug = self.title
      end
    end # Article
  end
end
