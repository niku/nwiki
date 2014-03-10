require 'rugged'
require 'forwardable'

module Nwiki
  module Core
    class Entry
      extend Forwardable

      attr_reader :path

      def initialize path, blob_object
        @path = path
        @blob_object = blob_object
      end

      def text
        @blob_object.text.force_encoding('UTF-8')
      end

      def_delegators :@blob_object, :size, :content, :binary?
    end

    class Diff
      extend Forwardable

      attr_reader :time

      def initialize entry, time
        @entry = entry
        @time = time
      end

      def_delegators :@entry, :size, :content, :text, :binary?, :path
    end

    class GitAccess
      def initialize repo_path
        @repo = Rugged::Repository.new(::File.expand_path(repo_path))
      end

      def config
        @repo.branches['config']
      end

      def title
        title_entry = config.target.tree.get_entry('title')
        title_blob = @repo.lookup(title_entry[:oid])
        title_blob.text.chomp.force_encoding('UTF-8')
      end

      def subtitle
        subtitle_entry = config.target.tree.get_entry('subtitle')
        subtitle_blob = @repo.lookup(subtitle_entry[:oid])
        subtitle_blob.text.chomp.force_encoding('UTF-8')
      end

      def author
        author_entry = config.target.tree.get_entry('author')
        author_blob = @repo.lookup(author_entry[:oid])
        author_blob.text.chomp.force_encoding('UTF-8')
      end

      def find_file
        target =  @repo.head.target
        target.tree.walk_blobs do |path, object|
          fullpath = path + object[:name]
          if yield(fullpath)
            return Entry.new(fullpath, @repo.lookup(object[:oid]))
          end
        end
      end

      def all_files
        walker = Rugged::Walker.new(@repo).tap do |w|
          w.sorting(Rugged::SORT_DATE) # new -> old
          w.push(@repo.head.target)
        end
        [].tap { |result|
          walker.walk.each do |commit|
            parent = commit.parents.first
            next unless parent
            diff = parent.diff(commit)
            diff.deltas.reject(&:deleted?).each do |delta|
              new_file_object = delta.new_file
              fullpath = new_file_object[:path].force_encoding('UTF-8')
              result << Entry.new(fullpath, @repo.lookup(new_file_object[:oid]))
            end
          end
        }.reduce([]) { |acm, e|
          acm.map(&:path).include?(e.path) ? acm : acm << e
        }.reject { |e|
          e.path.start_with?('__nwiki') # TODO HANDLE DELETED ELEMENT
        }
      end

      def log
        walker = Rugged::Walker.new(@repo).tap do |w|
          w.sorting(Rugged::SORT_DATE) # new -> old
          w.push(@repo.head.target)
        end
        [].tap do |result|
          walker.walk.each do |commit|
            commit_time = Time.at(commit.epoch_time)
            parent = commit.parents.first
            next unless parent
            diff = parent.diff(commit)
            diff.deltas.reject(&:deleted?).each do |delta|
              new_file_object = delta.new_file
              path = new_file_object[:path].force_encoding('UTF-8')
              result << Diff.new(Entry.new(path, @repo.lookup(new_file_object[:oid])), commit_time)
            end
          end
        end
      end
    end
  end
end
