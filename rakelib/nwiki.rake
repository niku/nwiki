require "rake/clean"

require "nwiki"

# An environment variable which is setted multibyte in Dockerhub get garbled.
# Workaround here
ENV["NWIKI_SITE_NAME"] = "ヽ（´・肉・｀）ノログ"

namespace :nwiki do
  temporary_path = ENV.fetch("NWIKI_TEMPORARY_PATH", "tmp")
  CLOBBER.include(temporary_path)

  desc "run the app"
  task :run do
    config = Nwiki::Config.fetch_from_environment_variable
    # docker を起動するときに -v `pwd`:/app/repo といった形でディレクトリをマウントする
    repository = Nwiki::Repository.new("/app/repo")
    # docker を起動するときに -v $PAGES:/app/pages といった形でディレクトリをマウントする
    output_directory = "/app/pages/"
    Nwiki::App.new(config, repository, output_directory).run
  end
end
