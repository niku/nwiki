require 'gollum-lib'
require 'rugged'
require 'forwardable'

module Nwiki
  module Core
    # copy from gollum
    GitAccess = ::Gollum::GitAccess

    class Entry
      extend Forwardable

      attr_reader :path

      def initialize path, blob_object
        @path = path
        @blob_object = blob_object
      end

      def_delegators :@blob_object, :size, :content, :text, :binary?
    end

    class NewGitAccess
      def initialize repo_path
        @repo = Rugged::Repository.new(::File.expand_path(repo_path))
      end

      def config
        Rugged::Branch.lookup(@repo, 'config')
      end

      def title
        title_entry = config.tip.tree.get_entry('title')
        title_blob = @repo.lookup(title_entry[:oid])
        title_blob.text.chomp
      end

      def subtitle
        subtitle_entry = config.tip.tree.get_entry('subtitle')
        subtitle_blob = @repo.lookup(subtitle_entry[:oid])
        subtitle_blob.text.chomp
      end

      def author
        author_entry = config.tip.tree.get_entry('author')
        author_blob = @repo.lookup(author_entry[:oid])
        author_blob.text.chomp
      end

      def find_file
        target =  @repo.head.target
        @repo.lookup(target).tree.walk_blobs do |path, object|
          fullpath = path + object[:name]
          if yield(fullpath)
            return Entry.new(fullpath, @repo.lookup(object[:oid]))
          end
        end
      end

      def all_files
        [].tap do |result|
          target =  @repo.head.target
          @repo.lookup(target).tree.walk_blobs do |path, object|
            fullpath = path + object[:name]
            result << Entry.new(fullpath, @repo.lookup(object[:oid]))
          end
        end
      end
    end
  end
end
