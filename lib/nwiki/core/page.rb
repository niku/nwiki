module Nwiki
  module Core
    class Page
      attr_reader :doc

      def initialize doc
        raise 'doc is empty or nil' unless doc
        @doc = doc
      end

      def encoding
        @doc.encoding
      end

      def == other
        return false unless other
        self.kind_of?(other.class) &&
        self.doc == other.doc
      end
    end
  end
end
