# -*- coding: utf-8 -*-
require 'erb'

module Nwiki
  module Frontend
    class Top
      def initialize git_repo_path, opts = {}
        @wiki = Nwiki::Core::Wiki.new git_repo_path
      end

      def call env
        [
          200,
          { "Content-Type" => "text/html; charset=#{Nwiki::Core::Wiki.repo_filename_encoding}" },
          [html]
        ]
      end

      def html
        erb = ERB.new <<EOS
<!doctype html>
<html>
<head>
  <meta http-equiv="refresh" content="5;URL=http://niku.name/articles/">
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= @wiki.title %></title>
  <link rel="alternate" type="application/atom+xml" title="ATOM Feed" href="/articles.xml">
  <link rel="stylesheet" href="/pure-min.css">
  <link rel="stylesheet" href="/nwiki.css">
  <link rel="stylesheet" href="/default.min.css">
  <link rel="stylesheet" href="/solarized_dark.css">
  <script src="/highlight.min.js"></script>
</head>

<body>
  <div class="header">
    <div class="home-menu pure-menu pure-menu-horizontal pure-menu-fixed">
      <h1><a class="pure-menu-heading" href="/articles/"><%= @wiki.title %></a></h1>
      <h2><%= @wiki.subtitle %></h2>
    </div>
  </div>

  <div class="content-wrapper">
    <div class="content">
      <div class="pure-g">
        <div class="pure-u-1">
          <p>ここまだ何にも作ってないんす．<a href="./articles/">articles</a>以下が動いているのでそっちを見てね．5秒経つと自動で移動します．</p>
        </div>
      </div>
    </div>
  </div>

  <div class="footer l-box is-center">
  </div>

  <script>Array.forEach(document.getElementsByClassName("src"), function(elem) { hljs.highlightBlock(elem) });</script>
</body>
</html>
EOS
        erb.result(binding).force_encoding(Nwiki::Core::Wiki.repo_filename_encoding)
      end
    end
  end
end
