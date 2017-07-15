require "rake/clean"
require "erb"

require "nwiki"

# An environment variable which is setted multibyte in Dockerhub get garbled.
# Workaround here
ENV["NWIKI_SITE_NAME"] = "ヽ（´・肉・｀）ノログ"

namespace :nwiki do
  temporary_path = ENV.fetch("NWIKI_TEMPORARY_PATH", "tmp")
  CLOBBER.include(temporary_path)

  desc "get head of a remote git repository"
  task :get_head do
    Nwiki.get_head(temporary_path, ENV.fetch("NWIKI_REPO"))
  end

  desc "convert from org to html contents"
  task :convert do
    Nwiki.convert(temporary_path)
  end

  desc "add metadata to converted html contents"
  task :add_metadata do
    Nwiki.add_metadata(temporary_path, ENV["NWIKI_ENDPOINT"])
  end

  desc "generate index"
  task :generate_index do
    Nwiki.generate_index(temporary_path, ENV["NWIKI_ENDPOINT"])
  end

  desc "add highlightjs to html contents"
  task :add_highlightjs do
    Nwiki.add_highlightjs(temporary_path)
  end

  desc "add analytics to html contents"
  task :add_analytics do
    Nwiki.add_analytics(temporary_path, ENV["NWIKI_TRACKING_ID"])
  end
end
