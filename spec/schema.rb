::ActiveRecord::Schema.define do

  create_table :api_users, :force => true do |t|
    t.string :name
    t.string :api_key
  end

  create_table :articles, :force => true do |t|
    t.string   :title
    t.string   :author
    t.text     :body
    t.timestamps
    t.datetime :published_at
    t.boolean  :deleted
    t.datetime :deleted_at
    t.string   :slug
    t.integer  :original_id
  end

  create_table :article_publications, :force => true do |t|
    t.integer  :article_id
    t.integer  :publication_id
  end

  create_table :bookmarks, :force => true do |t|
    t.string     :title
    t.boolean    :shared
    t.string     :uri
    t.text       :tags
  end

  create_table :comments, :force => true do |t|
    t.text     :body
    t.integer  :user_id
    t.timestamps
  end

  create_table :images, :force => true, :id => false do |t|
    t.string   :md5hash, :length => 32
    t.string   :title
    t.text     :description, :length => 1024
    t.integer  :width
    t.integer  :height
    t.string   :format
    t.time     :taken_at
  end
  add_index :images, :md5hash, :unique => true

  create_table :network_nodes, :force => true do |t|
    t.string     :ip_address
    t.integer    :cidr_subnet_bits
    t.string     :node_uuid
  end

  create_table :paragraphs, :force => true do |t|
    t.string   :text
    t.integer  :article_id
    t.timestamps
  end

  create_table :people, :force => true do |t|
    t.string :name
    t.text   :positions
    t.text   :inventions
    t.time   :birthday
    t.text   :interests
    t.string :password
  end

  create_table :software_packages, :force => true do |t|
    t.integer  :node_number
    t.string   :source_path
    t.string   :destination_path
    t.string   :product
    t.string   :version
    t.datetime :released_at
    t.boolean  :security_update
    t.datetime :installed_at
    t.string   :installed_by
  end

  create_table :tickets, :force => true do |t|
    t.string   :title
    t.text     :body
    t.integer  :status
  end

  create_table :tracks, :force => true do |t|
    t.string   :artist
    t.string   :name
    t.string   :album
    t.string   :musicbrainz_hash
  end
  add_index :tracks, [:artist, :album]
  add_index :tracks, :name
  add_index :tracks, :musicbrainz_hash, :unique => true

  create_table :tshirts, :force => true do |t|
    t.string   :writing
    t.boolean  :has_picture
    t.text     :picture
    t.text     :color
    t.text     :size
  end

  create_table :users, :force => true, :id => false, :primary_key => :name do |t|
    t.string  :name
    t.integer :age
    t.text    :summary
    t.text    :description
    t.boolean :admin
    t.integer :parent_id
    t.string  :referrer_id
  end
end
