require "rake/clean"
require "erb"

# An environment variable which is setted multibyte in Dockerhub get garbled.
# Workaround here
ENV["NWIKI_SITE_NAME"] = "ヽ（´・肉・｀）ノログ"

namespace :nwiki do
  temporary_path = ENV.fetch("NWIKI_TEMPORARY_PATH", "tmp")
  CLOBBER.include(temporary_path)

  template = ERB.new(<<__EOD__, nil, "-")
<!DOCTYPE html>
<html>
<head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# article: http://ogp.me/ns/article#">
<meta charset="UTF-8">
<meta name="viewport" content="width-device-width,initial-scale=1">
<title><%= title %> - <%= ENV['NWIKI_SITE_NAME'] %></title>
<meta content="<%= title %> - <%= ENV['NWIKI_SITE_NAME'] %>" name="title">
<% if description -%>
<meta content="<%= description %>" name="description">
<% end -%>

<meta property="og:type" content="article"/>
<meta property="og:title" content="<%= title %> - <%= ENV['NWIKI_SITE_NAME'] %>"/>
<% if description -%>
<meta property="og:description" content="<%= description %>" />
<% end -%>
<% if image_url -%>
<meta property="og:image" content="<%= image_url %>" />
<% end -%>
<meta property="og:url" content="<%= url %>" />
<meta property="og:site_name" content="<%= ENV['NWIKI_SITE_NAME'] %>"/>
</head>
<body>
<hgroup>
  <h1><a href="<%= ENV['NWIKI_ENDPOINT'] %>"><%= ENV['NWIKI_SITE_NAME'] %></a></h1>
  <h2><%= ENV['NWIKI_TAGLINE'] %></h2>
</hgroup>
<article>
<%= html_contents -%>
</article>
</body>
</html>
__EOD__

  desc "get head of a remote git repository"
  task :get_head do
    require "rugged"
    if File.exist?(temporary_path)
      repository = Rugged::Repository.discover(temporary_path)
      repository.fetch("origin")
      repository.reset("FETCH_HEAD", :hard)
    else
      Rugged::Repository.clone_at(ENV.fetch("NWIKI_REPO"), temporary_path)
    end
  end

  desc "convert from org to html contents"
  task :convert do
    require "org-ruby"
    FileList.new("#{temporary_path}/**/*.org").each do |path|
      new_path = File.join(File.dirname(path), File.basename(path, ".org") + ".html.contents")
      doc = File.read(path)
      html = Orgmode::Parser.new(doc, allow_include_files: true).to_html
      File.write(new_path, html)
      File.delete(path)
    end
  end

  desc "add metadata to converted html contents"
  task :add_metadata do
    require "oga"
    endpoint = ENV["NWIKI_ENDPOINT"]
    FileList.new("#{temporary_path}/**/*.html.contents").each do |path|
      new_path = File.join(File.dirname(path), File.basename(path, ".contents"))
      # `tmp/foo/bar.html` ->
      #     `foo/bar.html`
      dir_path_without_root = File.dirname(path).slice(temporary_path.length + 1..-1)
      url = if dir_path_without_root
              endpoint + dir_path_without_root + "/" + File.basename(path, ".contents")
            else
              endpoint + File.basename(path, ".contents")
            end
      title = File.basename(path, ".html.contents")
      html_contents = File.read(path)
      parsed_document = Oga.parse_html(html_contents)
      description = if desc = parsed_document.at_xpath("//p")
                      desc.text
                    end
      image = if img = parsed_document.at_xpath("//img/@src")
                img.value
              end
      image_url = if image
                    dir_path_without_root ? endpoint + dir_path_without_root + "/" + image : endpoint + image
                  end
      File.write(new_path, template.result(binding))
      File.delete(path)
    end
  end

  desc "generate index"
  task :generate_index do
    require 'uri'
    list = Dir
           .glob(File.join(temporary_path, "**", "*.html"))
           .map { |e| e.slice(temporary_path.length + 1..-1) }
           .map { |e| %Q(<li><a href="#{URI.escape(e)}">#{e.sub(/\.html$/, '')}</a></li>) }
           .sort
           .reverse
    title = "index"
    description = "index"
    image_url = nil
    url = ENV["NWIKI_ENDPOINT"] + "index.html"
    html_contents = "<h1>index</h1><ul>" << list.join("\n") << "</ul>"
    File.write(File.join(temporary_path, "index.html"), template.result(binding))
  end

  desc "add highlightjs to html contents"
  task :add_highlightjs do
    require "uri"
    require "net/http"
    require "pathname"
    Dir.chdir temporary_path do
      File.write("normalize.min.css", Net::HTTP.get(URI.parse("https://cdnjs.cloudflare.com/ajax/libs/normalize/4.2.0/normalize.min.css")))
      File.write("default.min.css", Net::HTTP.get(URI.parse("http://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.5.0/styles/default.min.css")))
      File.write("solarized-dark.css", Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/isagalaev/highlight.js/master/src/styles/solarized-dark.css")))
      File.write("nikulog.css", (Pathname.new(__FILE__).parent.parent + "assets" + "nikulog.css").read)
      File.write("highlight.min.js", Net::HTTP.get(URI.parse("http://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.5.0/highlight.min.js")))
      File.write("elixir.min.js", Net::HTTP.get(URI.parse("http://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.5.0/languages/elixir.min.js")))
    end

    root_path = Pathname.new(".")
    FileList.new("#{temporary_path}/**/*.html").each do |path|
      dir_path_without_root = File.dirname(path).slice(temporary_path.length + 1..-1)
      relative_path = if dir_path_without_root
                        root_path.relative_path_from(Pathname.new(dir_path_without_root)).to_s + "/"
                      else
                        ""
                      end
      parsed_document = Oga.parse_html(File.read(path))
      parsed_document.at_xpath("//head").children << Oga.parse_html(%Q!<link rel="stylesheet" href="#{relative_path}normalize.min.css">\n!).children.first
      parsed_document.at_xpath("//head").children << Oga.parse_html(%Q!<link rel="stylesheet" href="#{relative_path}default.min.css">\n!).children.first
      parsed_document.at_xpath("//head").children << Oga.parse_html(%Q!<link rel="stylesheet" href="#{relative_path}solarized-dark.css">\n!).children.first
      parsed_document.at_xpath("//head").children << Oga.parse_html(%Q!<link rel="stylesheet" href="#{relative_path}nikulog.css">\n!).children.first
      parsed_document.at_xpath("//body").children << Oga.parse_html(%Q!<script src="#{relative_path}highlight.min.js"></script>\n!).children.first
      parsed_document.at_xpath("//body").children << Oga.parse_html(%Q!<script src="#{relative_path}elixir.min.js"></script>\n!).children.first
      parsed_document.at_xpath("//body").children << Oga.parse_html(%Q!<script>Array.prototype.forEach.call(document.querySelectorAll("pre.src"), function(e){ hljs.highlightBlock(e) });</script>\n!).children.first
      File.write(path, parsed_document.to_xml)
    end
  end

  desc "add analytics to html contents"
  task :add_analytics do
    require "oga"
    tracking_id = ENV["NWIKI_TRACKING_ID"]
    script_tag = Oga.parse_html(<<__EOD__).children.first
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
      parsed_document = Oga.parse_html(File.read(path))
      # head タグ内の最後に script タグを追加する
      parsed_document.at_xpath("//head").children << script_tag
      File.write(path, parsed_document.to_xml)
    end
  end
end
