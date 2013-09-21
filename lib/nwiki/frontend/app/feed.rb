require 'rss'

module Nwiki
  module Frontend
    class Feed
      attr_reader :articles_path

      def initialize git_repo_path, opts = {}
        @wiki = Nwiki::Core::Wiki.new git_repo_path
        @articles_path = opts[:articles_path] || ''
      end

      def call env
        [
          200,
          { 'Content-Type' => "application/atom+xml; charset=#{Nwiki::Core::Wiki.repo_filename_encoding}" },
          [
            RSS::Maker.make('atom') { |maker|
              maker.channel.title = @wiki.title
              maker.channel.description = @wiki.subtitle
              maker.channel.link = Rack::Request.new(env).url

              maker.channel.author = @wiki.author
              maker.channel.date = @wiki.log.max_by(&:time).time
              maker.channel.id = Rack::Request.new(env).url

              maker.items.do_sort = true
              maker.items.max_size = 50

              @wiki.log.each do |diff|
                path = Nwiki::Core::Wiki.canonicalize_path(diff.path)
                path.gsub!(/\.org$/, '')

                maker.items.new_item do |item|
                  item.link = Rack::Request.new(env).url.gsub(Regexp.new(Rack::Request.new(env).fullpath), "#{articles_path}/#{path}")
                  item.title = File.basename(path)
                  item.date = diff.time
                end
              end
            }.to_s
          ]
        ]
      end
    end
  end
end
