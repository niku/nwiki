# -*- coding: utf-8 -*-
$LOAD_PATH << './lib'
require './lib/nwiki'

if ENV['RACK_ENV'] == "development"
  use Rack::Reloader
  use Rack::Lint
  use Rack::Static, :urls => {
        "/nwiki.css" => "public/nwiki.css",
        "/default.min.css" => "public/default.min.css",
        "/highlight.min.js" => "public/highlight.min.js",
        "/solarized_dark.css" => "public/solarized_dark.css"
      }
end

run Nwiki::Frontend::App.new 'spec/examples/sample.git'
