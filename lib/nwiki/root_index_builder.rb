# frozen_string_literal: true

module Nwiki
  class RootIndexBuilder
    # Boilerplate from https://github.com/h5bp/html5-boilerplate
    TEMPLATE = ERB.new(Pathname.new(__FILE__).dirname.join("index.html.erb").read, nil, "-")

    extend Forwardable
    def_delegators :@config, :endpoint, :site_name, :tagline, :ga_tracking_id

    # Initializes the root index object.
    #
    # @param config [Nwiki::Config]
    # @param html_metadatas [Array<HtmlMetadata>]
    def initialize(config, html_metadatas)
      @config = config
      @html_metadatas = html_metadatas
    end

    def path
      "index.html"
    end

    def description
      "Root page of #{site_name}"
    end

    def type
      "website"
    end

    def url
      endpoint
    end

    def title
      site_name
    end

    def image_url
      nil
    end

    def page_content
      @html_metadatas
        .reverse
        .map { |html_metadata| %Q!<a href="#{PageBuilder.org_url_to_html(html_metadata.path.escaped_name)}">#{PageBuilder.org_url_to_title(html_metadata.path.name)}</a>! }
        .join("</li><li>")
        .prepend("<ul><li>")
        .<<("</li></ul>")
    end

    def data
      TEMPLATE.result(binding)
    end
  end
end
