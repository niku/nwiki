module Nwiki
  module Core
    class Directory
      class << self
        attr_accessor :encoding
      end

      attr_reader :list

      def initialize path, list
        @path = path
        @list = list.
          select { |e| e =~ /\.org$/ }.
          map { |e| e.sub(/\.org$/){ '' } }
      end

      def title
        @path
      end

      def encoding
        self.class.encoding
      end

      def to_html
        '<ul>' + @list.map { |e|
          root = './'
          root << @path if @path != '/'
          %Q!<li><a href="#{root}#{e}">#{e}</a></li>!
        }.join + '</ul>'
      end
    end
  end
end
