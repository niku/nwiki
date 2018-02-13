# frozen_string_literal: true

require_relative "file"

module Nwiki
  class  Repository
    class Files
      include Enumerable

      # Initializes the files object in the repository.
      #
      # @param tree [Rugged::Repository]
      def initialize(repository)
        @repository = repository
      end

      def each
        return to_enum(__method__) unless block_given?

        @repository.head.target.tree.walk_blobs do |root, entry|
          yield File.new(@repository, root, entry)
        end
      end
    end
  end
end
