require 'rack'

module Nwiki
  module Core
    class Wiki
      def self.repo_filename_encoding
        Encoding::UTF_8
      end

      def self.parser
        Orgmode::Parser
      end

      def self.canonicalize_path path
        unescaped_path = URI.unescape(path).force_encoding(repo_filename_encoding)
        unescaped_path.sub(/^\//, '')
      end

      attr_reader :access

      def initialize path
        @path = path
        @access = GitAccess.new(path)
        @new_git_access = NewGitAccess.new(path)
      end

      def find path
        canonicalized_path = self.class.canonicalize_path path
        if canonicalized_path == ''
          find_directory(canonicalized_path)
        else
          find_page_or_file(canonicalized_path)
        end
      end

      def find_page_or_file path
        entry = @new_git_access.find_file do |entry_path|
          path == entry_path.sub(/\.org$/){ '' }
        end
        return nil unless entry
        if entry.path =~ /\.org$/
          Page.new(entry.path, entry.text, self.class.parser)
        else
          File.new(entry.path, entry.content)
        end
      end

      def find_directory path
        files = @new_git_access.all_files
        Directory.encoding = self.class.repo_filename_encoding
        Directory.new(path, files.map(&:path))
      end

      def title
        @new_git_access.title
      end

      def subtitle
        @new_git_access.subtitle
      end

      def author
        @new_git_access.author
      end

      def exist?
        @access.exist?
      end
    end
  end
end
