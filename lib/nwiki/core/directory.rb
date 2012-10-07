module Nwiki
  module Core
    class Directory
      attr_reader :list

      def initialize list
        @list = list.
          reject { |e| e =~ /^__nwiki/ }.
          map { |e| e.sub(/\.org$/){ '' } }
      end
    end
  end
end
