require "nwiki/version"

module Nwiki
  class << self
    def get_head(temporary_path, repo_url)
      require "rugged"
      if File.exist?(temporary_path)
        repository = Rugged::Repository.discover(temporary_path)
        repository.fetch("origin")
        repository.reset("FETCH_HEAD", :hard)
      else
        Rugged::Repository.clone_at(repo_url, temporary_path)
      end
    end
  end
end
