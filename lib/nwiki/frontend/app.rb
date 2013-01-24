require 'erb'

module Nwiki
  module Frontend
    class App
      def initialize git_repo_path
        @builder = Rack::Builder.new {
          map '/articles.xml' do
            run ->(env) { [200, { 'Content-Type' => "application/atom+xml; charset=#{Nwiki::Core::Wiki.repo_filename_encoding}" }, ['ok']] }
          end
          map '/articles' do
            run Html.new git_repo_path
          end
        }
      end

      def call env
        @builder.call env
      end
    end

    class Html
      def initialize git_repo_path
        @wiki = Nwiki::Core::Wiki.new git_repo_path
        raise unless @wiki.exist?
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
          [404, {"Content-Type" => "text/plane"}, ["not found."]]
        end
      end

      def html page
        erb = ERB.new <<EOS
<!DOCTYPE HTML>
<html>
<head>
  <title><%= page.title %> - <%= @wiki.name %></title>
  <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
  <script src="/bootstrap/js/bootstrap.min.js"></script>
</head>
<body>
<h1><%= @wiki.name %></h1>
<%= page.to_html %>
</body>
</html>
EOS
        erb.result(binding).force_encoding(page.encoding)
      end
    end
  end
end
