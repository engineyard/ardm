module ::ResourceBlog
  class User < Ardm::Record
    self.table_name = "users"

    property :name,        String, key: true
    property :age,         Integer
    property :summary,     Text
    property :description, Text
    property :admin,       Boolean, :accessor => :private

    belongs_to :parent, self, :required => false
    has n, :children, self, :inverse => :parent

    belongs_to :referrer, self, :required => false
    has n, :comments

    # FIXME: figure out a different approach than stubbing things out
    def comment=(*)
      # do nothing with comment
    end
  end

  class Author < User; end

  class Comment < Ardm::Record
    self.table_name = "comments"

    property :id,   Serial
    property :body, Text

    belongs_to :user
  end

  class Article < Ardm::Record
    self.table_name = "articles"

    property :id,   Serial
    property :body, Text

    has n, :paragraphs
  end

  class Paragraph < Ardm::Record
    self.table_name = "paragraphs"

    property :id,   Serial
    property :text, String

    belongs_to :article
  end
end

Ardm::Record.finalize

