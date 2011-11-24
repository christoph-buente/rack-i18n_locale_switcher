require 'rack/i18n_locale_switcher'
require 'rack/test'

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Rack::Test::Methods
end
