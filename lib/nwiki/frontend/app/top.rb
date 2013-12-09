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
<!DOCTYPE HTML>
<html>
<head>
  <meta http-equiv="refresh" content="5;URL=http://niku.name/articles/">
  <title><%= @wiki.title %></title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="alternate" type="application/atom+xml" title="ATOM Feed" href="/articles.xml">
  <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css">
  <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap-theme.min.css">
</head>
<body>
  <a href="https://github.com/niku/nikulog">
    <img style="position: absolute; top: 0; right: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_right_orange_ff7600.png" alt="Fork me on GitHub">
  </a>
  <div class="container">
    <div class="row">
      <div class="col-md-8"><h1><a href="/articles/"><%= @wiki.title %></a></h1></div>
    </div>
    <div class="row">
      <div class="col-md-12"><h2"><small><%= @wiki.subtitle %></small></h2></div>
    </div>
    <div class="row">
      <div class="col-md-12">
        <p>ここまだ何にも作ってないんす．<a href="./articles/">articles</a>以下が動いているのでそっちを見てね．5秒経つと自動で移動します．</p>
      </div>
    </div>
  </div>
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
  <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.3/js/bootstrap.min.js"></script>
</body>
</html>
EOS
        erb.result(binding).force_encoding(Nwiki::Core::Wiki.repo_filename_encoding)
      end
    end
  end
end
