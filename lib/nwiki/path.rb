# frozen_string_literal: true

require "erb"
require "pathname"

module Nwiki
  class Path
    class << self
      def escape(path)
        path
          .split("/", -1)
          .map { |e| ERB::Util.url_encode(e) }
          .join("/")
      end
    end

    include Comparable

    # Initializes the representation of a path.
    #
    # @param dirname [String]
    # @param basename [String]
    def initialize(dirname, basename)
      @dirname = Pathname.new(dirname)
      @basename = Pathname.new(basename)
    end

    def <=>(other)
      self.name <=> other.name
    end

    def dirname
      @dirname.to_s
    end

    def escaped_dirname
      self.class.escape(dirname)
    end

    def basename
      @basename.to_s
    end

    def escaped_basename
      self.class.escape(basename)
    end

    def name
      (@dirname + @basename).to_s
    end

    def escaped_name
      self.class.escape(name)
    end

    def extname
      @basename.extname
    end

    def escaped_extname
      self.class.escape(extname)
    end
  end
end
