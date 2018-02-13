# frozen_string_literal: true

require "rugged"
require_relative "repository/files"

module Nwiki
  class Repository
    class OSError < RuntimeError
      attr_reader :raw_error

      def initialize(raw_error)
        @raw_error = raw_error
        super(raw_error.message)
      end
    end

    def initialize(path)
      @repository = Rugged::Repository.new(::File.expand_path(path))
    rescue Rugged::OSError => e
      raise OSError.new(e)
    end

    def files
      Files.new(@repository)
    end
  end
end
