# -*- coding: utf-8 -*-
require_relative 'app/top'
require_relative 'app/feed'
require_relative 'app/html'

module Nwiki
  module Frontend
    class App
      def initialize git_repo_path
        @builder = Rack::Builder.new {
          map '/' do
            run Top.new git_repo_path
          end
          map '/articles.xml' do
            run Feed.new git_repo_path, articles_path: '/articles'
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
  end
end
