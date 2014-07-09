# -*- coding: utf-8 -*-
require 'rack/rewrite'
require 'rack/git'
require 'org-ruby'

require_relative 'app/top'
require_relative 'app/feed'
require_relative 'app/html'

module Nwiki
  module Frontend
    class App
      def template(wiki, page_title, html)
        erb = ERB.new <<EOS
<!DOCTYPE HTML>
<html>
<head>
  <title><%= page_title %><%= wiki.title %></title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="alternate" type="application/atom+xml" title="ATOM Feed" href="/articles.xml">
  <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
  <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css">
</head>
<body>
  <a href="https://github.com/niku/nikulog">
    <img style="position: absolute; top: 0; right: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_right_orange_ff7600.png" alt="Fork me on GitHub">
  </a>
  <div class="container">
    <div class="row">
      <div class="col-md-12"><h1><a href="/articles/"><%= wiki.title %></a></h1></div>
    </div>
    <div class="row">
      <div class="col-md-12"><h2"><small><%= wiki.subtitle %></small></h2></div>
    </div>
    <div class="row">
      <div class="col-md-12">
        <%= html %>
      </div>
    </div>
  </div>
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
  <script src="//netdna.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
</body>
</html>
EOS
        erb.result(binding).force_encoding("UTF-8")
      end

      def initialize git_repo_path
        Rack::Mime::MIME_TYPES.merge!({ ".org" => "text/html" })

        wiki = Core::Wiki.new git_repo_path
        file_converter = -> (file, env) {
          path = Rack::Utils.unescape(env["PATH_INFO"])
          return file if ::File.extname(path) != ".org"
          file.force_encoding("UTF-8")
          page_title = path.empty? ? '' : "#{path.gsub(/\.org$/, '').gsub(/^\//, '')} - "
          html = if ::File.extname(path) == ".org"
                   Orgmode::Parser.new(file, offset: 1).to_html
                 else
                   file
                 end
          template(wiki, page_title, html)
        }
        directory_converter = -> (dirs, env) {
          path = Rack::Utils.unescape(env["PATH_INFO"])
          if path == '/'
            page_title = path.empty? ? '' : "#{path.gsub(/\.org$/, '').gsub(/^\//, '')} - "
            html = wiki.find_directory("/").to_html
            template(wiki, page_title, html)
          else
            dirs.each { |d| d.force_encoding("UTF-8") }
            page_title = path.empty? ? '' : "#{path.gsub(/\.org$/, '').gsub(/^\//, '')} - "
            list = dirs.map { |e| %Q!<li><a href="#{e.gsub(/\.org/, '')}">#{e.gsub(/\.org/, '')}</a></li>! }
            html = "<ul><li><a href=\"../\">../</a></li>#{list.join}</ul>"
            template(wiki, page_title, html)
          end
        }

        @builder = Rack::Builder.new {
          map '/' do
            run Top.new git_repo_path
          end
          map '/articles.xml' do
            run Feed.new git_repo_path, articles_path: '/articles'
          end
          map '/articles' do
            use Rack::Rewrite do
              rewrite %r{^(.*)$}, '$1.org', if: -> (env) {
                path = Rack::Utils.unescape(env["PATH_INFO"])
                path !~ /\/$/ && File.extname(path) !~ /(png|jpg|gif)/
              }
            end
            run Rack::Git::File.new git_repo_path, file_converter: file_converter, directory_converter: directory_converter
          end
        }
      end

      def call env
        @builder.call env
      end
    end
  end
end
