# -*- coding: utf-8 -*-
$LOAD_PATH << './lib'
require './lib/nwiki'

if ENV['RACK_ENV'] == "development"
  use Rack::Reloader
  use Rack::Lint
  use Rack::Static, :urls => {
        "/pure-min.css" => "public/pure-min.css",
        "/nwiki.css" => "public/nwiki.css"
      }
end

run Nwiki::Frontend::App.new 'spec/examples/sample.git'
