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
          [200, {"Content-Type" => "text/html; charset=#{page.encoding}"}, [Orgmode::Parser.new(page.doc, 1).to_html]]
        else
          [404, {"Content-Type" => "text/plane"}, ["not found."]]
        end
      end
    end
  end
end
