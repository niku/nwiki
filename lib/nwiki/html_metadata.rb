# frozen_string_literal: true

require "forwardable"
require "nokogiri"
require "pathname"

module Nwiki
  class HtmlMetadata
    extend Forwardable
    def_delegators :@html_fragment, :path, :read

    # Initializes the converter object.
    #
    # @param html_fragment [Nwiki::HtmlFragment]
    def initialize(html_fragment)
      @html_fragment = html_fragment
    end

    def url
      @html_fragment.path.name
    end

    def image_url
      element = Nokogiri::HTML
                  .fragment(@html_fragment.read)
                  .at_css('img:not([href^="http"])')
      if element
        Pathname.new(@html_fragment.path.dirname).join(element["src"]).to_s
      else
        nil
      end
    end

    def type
      "article"
    end

    def title
      Pathname.new(@html_fragment.path.basename).basename(".*").to_s
    end

    def description
      dom = Nokogiri::HTML
              .fragment(@html_fragment.read)
              .css("p")
              .find { |e| !e.text.empty? }
      dom.text if dom
    end
  end
end
