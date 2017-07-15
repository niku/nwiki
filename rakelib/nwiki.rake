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
    require "nokogiri"
    tracking_id = ENV["NWIKI_TRACKING_ID"]
    script_tag = Nokogiri::HTML(<<__EOD__).children.first
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', '#{tracking_id}', 'auto');
  ga('send', 'pageview');

</script>

__EOD__
    FileList.new("#{temporary_path}/**/*.html").each do |path|
      parsed_document = Nokogiri::HTML(File.read(path))
      # head タグ内の最後に script タグを追加する
      parsed_document.at_xpath("//head").children << script_tag
      File.write(path, parsed_document.to_xml)
    end
  end
end
