# frozen_string_literal: true

require "erb"
require "nokogiri"
require "pathname"
require "rouge"

module Nwiki
  class PageBuilder
    class << self
      def escape(path)
        path
          .split("/")
          .map { |e| ERB::Util.url_encode(e) }
          .join("/")
      end

      def org_url_to_html(url)
        return unless url
        url.sub(/\.org\z/, ".html")
      end

      def org_url_to_title(url)
        return unless url
        url.sub(/\.org\z/, "")
      end
    end

    # Boilerplate from https://github.com/h5bp/html5-boilerplate
    TEMPLATE = ERB.new(Pathname.new(__FILE__).dirname.join("index.html.erb").read, nil, "-")

    extend Forwardable
    def_delegators :@config, :endpoint, :site_name, :tagline, :ga_tracking_id
    def_delegators :@html_metadata, :path, :type, :title, :description

    # Initializes the page builder object.
    #
    # @param config [Nwiki::Config]
    # @param html_metadata [HtmlMetadata]
    # @param html_metalink [HtmlMetalink]
    def initialize(config, html_metadata, html_metalink)
      @config = config
      @html_metadata = html_metadata
      @html_metalink = html_metalink
    end

    def url
      html_url = self.class.org_url_to_html(@html_metadata.url)
      (@config.endpoint + self.class.escape(html_url)).to_s
    end

    def image_url
      image_url = @html_metadata.image_url
      if image_url
        (@config.endpoint + self.class.escape(image_url)).to_s
      end
    end

    def prev_of
      page = self.class.org_url_to_html(@html_metalink.prev_of(@html_metadata.url))
      if page
        (@config.endpoint + self.class.escape(page)).to_s
      end
    end

    def next_of
      page = self.class.org_url_to_html(@html_metalink.next_of(@html_metadata.url))
      if page
        (@config.endpoint + self.class.escape(page)).to_s
      end
    end

    def linked_from
      []
    end

    def read
      html = Nokogiri::HTML.fragment(@html_metadata.read)
      html.css("pre.src").each do |element|
        lang = element["lang"]
        lexer = Rouge::Lexer.find(lang)
        if lexer
          formatter = Rouge::Formatters::HTML.new
          formatted = formatter.format(lexer.lex(element.content))
          element.inner_html = Nokogiri::HTML.fragment(formatted)
        end
      end
      page_content = html.to_html
      TEMPLATE.result(binding)
    end
  end
end
