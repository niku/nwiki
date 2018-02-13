# frozen_string_literal: true

require "cgi"
require "pathname"

module Nwiki
  class  Repository
    class File
      def initialize(repository, root, entry)
        @repository = repository
        @root = root
        @entry = entry
      end

      def path
        Path.new(@root, @entry[:name])
      end

      def read
        blob = @repository.lookup(@entry[:oid])
        if blob.binary?
          blob.content
        else
          blob.text(-1, Encoding::UTF_8)
        end
      end
    end
  end
end
