# -*- coding: utf-8 -*-
$LOAD_PATH << './lib'
require './lib/nwiki'

if ENV['RACK_ENV'] == "development"
  use Rack::Reloader
  use Rack::Lint
  use Rack::Static, :urls => {
        "/pure-min.css" => "public/pure-min.css",
        "/nwiki.css" => "public/nwiki.css",
        "/default.min.css" => "public/default.min.css",
        "/highlight.min.js" => "public/highlight.min.js"
      }
end

run Nwiki::Frontend::App.new 'spec/examples/sample.git'
