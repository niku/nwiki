module Nwiki
  module Core
    class Wiki
      def self.repo_filename_encoding
        Encoding::UTF_8
      end

      def self.canonicalize_path path
        unescaped_path = URI.unescape(path).force_encoding(repo_filename_encoding)
        unescaped_path.sub(/^\//, '')
      end

      def initialize path
        @path = path
        @access = GitAccess.new(path)
      end

      def find path
        canonicalized_path = self.class.canonicalize_path path
        blob_entry = @access
          .tree('master')
          .find { |e| canonicalized_path == e.path.sub(/\.org$/){ '' } }
        Page.new(blob_entry.blob(@access.repo).data) if blob_entry
      end

      def exist?
        @access.exist?
      end
    end
  end
end
