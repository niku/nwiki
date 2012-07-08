require 'erb'

module Nwiki
  module Frontend
    class App
      def initialize git_repo_path
        @wiki = Nwiki::Core::Wiki.new git_repo_path
        raise unless @wiki.exist?
      end

      def call env
        path_info = env["PATH_INFO"]
        page = @wiki.find path_info
        if page
          [200, {"Content-Type" => "text/html; charset=#{page.encoding}"}, [html(page)]]
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
