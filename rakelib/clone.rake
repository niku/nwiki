require "rugged"

desc "clone a git repository via network"
namespace :nwiki do
  task :clone do
    Rugged::Repository.clone_at(ENV.fetch("NWIKI_REPO"), "tmp")
  end
end
