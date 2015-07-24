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
      Rack::Mime::MIME_TYPES.merge!({ ".org" => "text/html" })

      TEMPLATE = -> (wiki, page_title, html) {
        erb = ERB.new <<EOS
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= page_title %><%= wiki.title %></title>
  <link rel="alternate" type="application/atom+xml" title="ATOM Feed" href="/articles.xml">
  <link rel="stylesheet" href="/pure-min.css">
  <link rel="stylesheet" href="/nwiki.css">
  <link rel="stylesheet" href="/default.min.css">
  <link rel="stylesheet" href="/solarized_dark.css">
  <script src="/highlight.min.js"></script>
</head>

<body>
  <div class="header">
    <div class="home-menu pure-menu pure-menu-horizontal pure-menu-fixed">
      <h1><a class="pure-menu-heading" href="/articles/"><%= wiki.title %></a></h1>
      <h2><%= wiki.subtitle %></h2>
    </div>
  </div>

  <div class="content-wrapper">
    <div class="content">
      <div class="pure-g">
        <div class="pure-u-1">
          <%= html %>
        </div>
      </div>
    </div>
  </div>

  <div class="footer l-box is-center">
  </div>

  <script>Array.prototype.forEach.call(document.querySelectorAll("pre.src"), function(e){ hljs.highlightBlock(e) });</script>
</body>
</html>
EOS
        erb.result(binding).force_encoding("UTF-8")
      }

      FILE_CONVERTER = -> (wiki, template, file, env) {
        path = Rack::Utils.unescape(env["PATH_INFO"])
        return file unless Nwiki::Utils.orgfile?(path)
        page_title = Nwiki::Utils.page_title(path)
        file.force_encoding("UTF-8")
        html = Orgmode::Parser.new(file, offset: 1).to_html
        template.call(wiki, page_title, html)
      }.curry

      DIRECTORY_CONVERTER = -> (wiki, template, file, env) {
        path = Rack::Utils.unescape(env["PATH_INFO"])
        if path == '/'
          page_title = Nwiki::Utils.page_title(path)
          html = wiki.find_directory("/").to_html
          template.call(wiki, page_title, html)
        else
          page_title = Nwiki::Utils.page_title(path)
          list = dirs.
            each { |d| d.force_encoding("UTF-8") }.
            map  { |e| Nwiki::Utils.strip_org(e) }.
            map  { |e| %Q!<li><a href="#{e.gsub('#', '%23')}">#{e}</a></li>! }
          html = "<ul><li><a href=\"../\">../</a></li>#{list.join}</ul>"
          template.call(wiki, page_title, html)
        end
      }.curry

      def initialize git_repo_path
        wiki = Core::Wiki.new git_repo_path

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
            run Rack::Git::File.new git_repo_path,
              file_converter: FILE_CONVERTER.call(wiki, TEMPLATE),
              directory_converter: DIRECTORY_CONVERTER.call(wiki, TEMPLATE)
          end
        }
      end

      def call env
        @builder.call env
      end
    end
  end
end
