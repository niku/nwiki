require 'gollum-lib'
require 'rugged'

module Nwiki
  module Core
    # copy from gollum
    GitAccess = ::Gollum::GitAccess
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
    end
  end
end
