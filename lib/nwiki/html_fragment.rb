# frozen_string_literal: true

require "forwardable"
require "org-ruby"

module Nwiki
  class HtmlFragment
    extend Forwardable
    def_delegators :@file, :path

    # Initializes the converter object.
    #
    # @param file [Nwiki::Repository::File]
    def initialize(file)
      @file = file
    end

    def read
      Orgmode::Parser.new(@file.read, allow_include_files: true).to_html
    end
  end
end
