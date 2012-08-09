module Nwiki
  module Core
    class File
      attr_reader :data, :content_type

      def initialize name, data
        @data = data
        @content_type = Rack::Mime.mime_type(::File.extname(name))
      end
    end
  end
end
