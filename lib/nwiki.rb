require "nwiki/version"

module Nwiki
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
  end
end
