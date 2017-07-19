require "nwiki/version"
require "logger"

module Nwiki
  LOGGER = Logger.new(STDOUT)

  class << self
    def template
      ERB.new(<<__EOD__, nil, "-")
<!DOCTYPE html>
<html lang="ja">
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
<h1><a href="<%= ENV['NWIKI_ENDPOINT'] %>"><%= ENV['NWIKI_SITE_NAME'] %></a></h1>
<h2><%= ENV['NWIKI_TAGLINE'] %></h2>
<article>
<%= html_contents -%>
</article>
</body>
</html>
__EOD__
    end

    def get_head(temporary_path, repo_url)
      LOGGER.info("get_head(#{temporary_path}, #{repo_url})")
      require "rugged"
      if File.exist?(temporary_path)
        repository = Rugged::Repository.discover(temporary_path)
        repository.fetch("origin")
        repository.reset("FETCH_HEAD", :hard)
      else
        Rugged::Repository.clone_at(repo_url, temporary_path)
      end
    end

    def convert(temporary_path)
      LOGGER.info("convert(#{temporary_path})")
      require "org-ruby"
      FileList.new("#{temporary_path}/**/*.org").each do |path|
        new_path = File.join(File.dirname(path), File.basename(path, ".org") + ".html.contents")
        doc = File.read(path)
        html = Orgmode::Parser.new(doc, allow_include_files: true).to_html
        File.write(new_path, html)
        File.delete(path)
      end
    end

    def add_metadata(temporary_path, endpoint)
      LOGGER.info("add_metadata(#{temporary_path}, #{endpoint})")
      require "nokogiri"
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
        parsed_document = Nokogiri::HTML(html_contents)
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

    def generate_index(temporary_path, endpoint)
      LOGGER.info("generate_index(#{temporary_path}, #{endpoint})")
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

    def add_highlightjs(temporary_path)
      LOGGER.info("add_highlights(#{temporary_path})")
      require "rake" # For FileLIst module
      require "uri"
      require "net/http"
      require "pathname"
      require "nokogiri"
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
        parsed_document.at_xpath("//head") << %Q!<link rel="stylesheet" href="#{relative_path}normalize.min.css">\n!
        parsed_document.at_xpath("//head") << %Q!<link rel="stylesheet" href="#{relative_path}default.min.css">\n!
        parsed_document.at_xpath("//head") << %Q!<link rel="stylesheet" href="#{relative_path}solarized-dark.css">\n!
        parsed_document.at_xpath("//head") << %Q!<link rel="stylesheet" href="#{relative_path}nikulog.css">\n!
        parsed_document.at_xpath("//body") << %Q!<script src="#{relative_path}highlight.min.js"></script>\n!
        parsed_document.at_xpath("//body") << %Q!<script src="#{relative_path}elixir.min.js"></script>\n!
        parsed_document.at_xpath("//body") << %Q!<script>Array.prototype.forEach.call(document.querySelectorAll("pre.src"), function(e){ hljs.highlightBlock(e) });</script>\n!
        File.write(path, parsed_document.to_xml)
      end
    end

    def add_analytics(temporary_path, tracking_id)
      LOGGER.info("add_analytics(#{temporary_path}, #{tracking_id})")
      require "nokogiri"
      script_tag = <<__EOD__
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
        parsed_document.at_xpath("//head") << script_tag
        File.write(path, parsed_document.to_xml)
      end
    end
  end
end
