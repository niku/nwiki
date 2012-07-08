# -*- coding: utf-8 -*-
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

      def initialize path
        @path = path
        @access = GitAccess.new(path)
      end

      def find path
        canonicalized_path = self.class.canonicalize_path path
        blob_entry = @access
          .tree('master')
          .find { |e| canonicalized_path == e.path.sub(/\.org$/){ '' } }
        return nil unless blob_entry
        byte_string = blob_entry.blob(@access.repo).data
        byte_string.force_encoding(self.class.repo_filename_encoding)
        Page.new(::File.basename(blob_entry.name, '.org'), byte_string, self.class.parser)
      end

      def name
        blob_entry = @access
          .tree('master')
          .find { |e| e.path == '__nwiki/name' }
        return '' unless blob_entry
        byte_string = blob_entry.blob(@access.repo).data
        byte_string.force_encoding(self.class.repo_filename_encoding)
        byte_string.chomp
      end

      def exist?
        @access.exist?
      end
    end
  end
end
