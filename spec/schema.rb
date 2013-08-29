ActiveRecord::Schema.define do

  create_table :api_users, :force => true do |t|
    t.string :name
    t.string :api_key
  end

  create_table :articles, :force => true do |t|
    t.string   :title
    t.text     :body
    t.timestamps
    t.datetime :published_at
    t.boolean  :deleted
    t.datetime :deleted_at
    t.string   :slug
  end

  create_table :bookmarks, :force => true do |t|
    t.string     :title
    t.boolean    :shared
    t.string     :uri
    t.text       :tags
  end

  create_table :network_nodes, :force => true do |t|
    t.string     :ip_address
    t.integer    :cidr_subnet_bits
    t.string     :node_uuid
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
    t.datetime :nstalled_at
    t.string   :nstalled_by
  end

  create_table :tickets, :force => true do |t|
    t.string   :title
    t.text     :body
    t.text     :status
  end

  create_table :tshirts, :force => true do |t|
    t.string   :writing
    t.boolean  :has_picure
    t.text     :picture
    t.text     :color
    t.text     :size
  end
end
