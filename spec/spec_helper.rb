$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'closet'
require 'helpers/test_db'
require 'helpers/models'
require 'helpers/rspec'
require 'factory_girl'
require 'pry'
require 'database_cleaner'
require 'factories'


# Setup DB
Helpers::TestDB.setup!
# Setup ActiveRecord models
include Helpers::Models

RSpec.configure do |config|


#  FactoryGirl.definition_file_paths = %w{./}
#  FactoryGirl.find_definitions

  config.include FactoryGirl::Syntax::Methods
  config.include Helpers::Rspec

  # Setup Database Cleaner
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

end
