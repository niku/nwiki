require 'nwiki'
require 'rack/test'
require 'coveralls'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include Rack::Test::Methods
end

Coveralls.wear!
