require 'pry'

require 'active_record'
require 'database_cleaner'
require 'ardm-property'
require 'ardm-property/rails'

#ActiveRecord::Base.extend Ardm::Property::Lookup
#ActiveRecord::Base.extend Ardm::Property::ClassMethods

ActiveRecord::Base.configurations = { "ardm-property" => {
    "database" => "db/test.sqlite",
    "adapter" => "sqlite3"
  }}
ActiveRecord::Base.establish_connection 'ardm-property'

begin
  $stdout = StringIO.new
  load Pathname.new(__FILE__).dirname.expand_path.join("schema.rb")
ensure
  $stdout = STDOUT
end

Dir["#{Pathname(__FILE__).dirname.expand_path}/shared/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

DEPENDENCIES = {
  'bcrypt' => 'bcrypt-ruby',
}

def try_spec
  begin
    yield
  rescue LoadError => error
    match = error.message.match(/\Ano such file to load -- (.+)\z/)
    raise error unless match && (lib = match[1])

    gem_location = DEPENDENCIES[lib] || raise("Unknown lib #{lib}")

    warn "[WARNING] Skipping specs using #{lib}, please do: gem install #{gem_location}"
  end
end
