require 'erb'

module Nwiki
  module Frontend
    class Html
      def initialize git_repo_path
        @wiki = Nwiki::Core::Wiki.new git_repo_path
      end

      def call env
        path_info = env["PATH_INFO"]
        page = @wiki.find path_info
        case page
        when Core::Page, Core::Directory
          [200, {"Content-Type" => "text/html; charset=#{page.encoding}"}, [html(page)]]
        when Core::File
          [200, {"Content-Type" => page.content_type}, [page.data]]
        else
          [404, {"Content-Type" => "text/plain"}, ["not found."]]
        end
      end

      def html page
        page_title = page.title.empty? ? '' : "#{page.title} - "
        erb = ERB.new <<EOS
<!DOCTYPE HTML>
<html>
<head>
  <title><%= page_title %><%= @wiki.title %></title>
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
      <div class="col-md-12"><h1><a href="/articles/"><%= @wiki.title %></a></h1></div>
    </div>
    <div class="row">
      <div class="col-md-12"><h2"><small><%= @wiki.subtitle %></small></h2></div>
    </div>
    <div class="row">
      <div class="col-md-12">
        <%= page.to_html %>
      </div>
    </div>
  </div>
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
  <script src="//netdna.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
</body>
</html>
EOS
        erb.result(binding).force_encoding(page.encoding)
      end
    end
  end
end
