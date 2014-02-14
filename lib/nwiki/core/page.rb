module Nwiki
  module Core
    class Page
      attr_reader :title, :doc

      def initialize title, doc, parser_class
        raise 'title is empty or nil' unless title
        raise 'doc is empty or nil' unless doc
        raise 'parser_class is empty or nil' unless parser_class
        @title, @doc, @parser_class = title, doc, parser_class
      end

      def encoding
        @doc.encoding
      end

      def to_html
        @parser_class.new(@doc, offset: 1).to_html
      end

      def == other
        return false unless other
        self.kind_of?(other.class) &&
        self.doc == other.doc
      end
    end
  end
end
