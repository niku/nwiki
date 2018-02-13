# frozen_string_literal: true

require "nokogiri"

module Nwiki
  class HtmlMetalink
    Link = Struct.new(:prev, :next, :from)

    # Initializes the converter object.
    #
    # @param html_fragments [Array<Nwiki::HtmlFragment>]
    def initialize(html_fragments)
      @html_fragments = html_fragments
      @links = calc(@html_fragments)
    end

    def prev_of(path)
      link = @links[path]
      return if link.nil?
      link.prev
    end

    def next_of(path)
      link = @links[path]
      return if link.nil?
      link.next
    end

    def links_for(_path)
      [] # TODO
    end

    private
    def calc(html_fragments)
      links = Hash.new { Link.new }

      html_fragments
        .sort_by(&:path)
        .partition { |html_fragment| html_fragment.path.name =~ %r!\A\d{4}/\d{2}/\d{2}/! } # Assume a diary starts with `yyyy/mm/dd/`
        .each do |html_fragment|
          html_fragment.each_cons(2).each do |f, s|
            link = links[f.path.name]
            link.next = s.path.name
            links[f.path.name] = link

            link = links[s.path.name]
            link.prev = f.path.name
            links[s.path.name] = link
          end
        end
      links
    end
  end
end
