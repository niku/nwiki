# -*- coding: utf-8 -*-
$LOAD_PATH << './lib'
require './lib/nwiki'

if ENV['RACK_ENV'] == "development"
  use Rack::Reloader
  use Rack::Lint
end

run Nwiki::Frontend::App.new 'spec/examples/sample.git'
