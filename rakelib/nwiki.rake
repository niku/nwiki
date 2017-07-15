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
    require "uri"
    require "net/http"
    require "pathname"
    Dir.chdir temporary_path do
      File.write("normalize.min.css", Net::HTTP.get(URI.parse("https://cdnjs.cloudflare.com/ajax/libs/10up-sanitize.css/5.0.0/sanitize.min.css")))
      File.write("default.min.css", Net::HTTP.get(URI.parse("https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.10.0/styles/default.min.css")))
      File.write("solarized-dark.css", Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/isagalaev/highlight.js/master/src/styles/solarized-dark.css")))
      File.write("nikulog.css", (Pathname.new(__FILE__).parent.parent + "assets" + "nikulog.css").read)
      File.write("highlight.min.js", Net::HTTP.get(URI.parse("https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.10.0/highlight.min.js")))
      File.write("elixir.min.js", Net::HTTP.get(URI.parse("https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.10.0/languages/elixir.min.js")))
    end

    root_path = Pathname.new(".")
    FileList.new("#{temporary_path}/**/*.html").each do |path|
      dir_path_without_root = File.dirname(path).slice(temporary_path.length + 1..-1)
      relative_path = if dir_path_without_root
                        root_path.relative_path_from(Pathname.new(dir_path_without_root)).to_s + "/"
                      else
                        ""
                      end
      parsed_document = Nokogiri::HTML(File.read(path))
      parsed_document.at_xpath("//head").children << Nokogiri::HTML(%Q!<link rel="stylesheet" href="#{relative_path}normalize.min.css">\n!).children.first
      parsed_document.at_xpath("//head").children << Nokogiri::HTML(%Q!<link rel="stylesheet" href="#{relative_path}default.min.css">\n!).children.first
      parsed_document.at_xpath("//head").children << Nokogiri::HTML(%Q!<link rel="stylesheet" href="#{relative_path}solarized-dark.css">\n!).children.first
      parsed_document.at_xpath("//head").children << Nokogiri::HTML(%Q!<link rel="stylesheet" href="#{relative_path}nikulog.css">\n!).children.first
      parsed_document.at_xpath("//body").children << Nokogiri::HTML(%Q!<script src="#{relative_path}highlight.min.js"></script>\n!).children.first
      parsed_document.at_xpath("//body").children << Nokogiri::HTML(%Q!<script src="#{relative_path}elixir.min.js"></script>\n!).children.first
      parsed_document.at_xpath("//body").children << Nokogiri::HTML(%Q!<script>Array.prototype.forEach.call(document.querySelectorAll("pre.src"), function(e){ hljs.highlightBlock(e) });</script>\n!).children.first
      File.write(path, parsed_document.to_xml)
    end
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
