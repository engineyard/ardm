source 'https://rubygems.org'

gemspec

gem 'pry'
gem 'pry-nav'
gem 'awesome_print'

group :test do
  gem 'sqlite3'
  gem 'activerecord', '~> 4.0.0'
  gem 'addressable'
  gem 'database_cleaner'
  gem 'rspec-its'
end

group :datamapper do
  gem 'dm-core', '~> 1.2'
  gem 'dm-sqlite-adapter', '~> 1.2'
  gem 'dm-types', '~> 1.2', git: "git://github.com/engineyard/dm-types.git", branch: "1.2-multijson"
  gem 'dm-validations', '~> 1.2'
  gem 'dm-transactions', '~> 1.2'
  gem 'dm-migrations', '~> 1.2'
end
