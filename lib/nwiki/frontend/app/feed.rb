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
              maker.channel.date = latest_update
              maker.channel.id = Rack::Request.new(env).url

              maker.items.do_sort = true
              maker.items.max_size = 50

              log = @wiki.access.repo.log
              log.each do |commit|
                date = commit.date
                commit.show.each do |diff|
                  next unless diff.new_file

                  path = Nwiki::Core::Wiki.canonicalize_path(diff.b_path)
                  path.gsub!(/\.org$/, '')

                  maker.items.new_item do |item|
                    item.link = Rack::Request.new(env).url.gsub(Regexp.new(Rack::Request.new(env).fullpath), "#{articles_path}/#{path}")
                    item.title = File.basename(path)
                    item.date = date
                  end
                end
              end
            }.to_s
          ]
        ]
      end

      private
      def latest_update
        log = @wiki.access.repo.log
        latest_update = Time.parse('1900-01-01')
        log.each do |commit|
          latest_update = commit.date if commit.date > latest_update
        end
        latest_update
      end
    end
  end
end
