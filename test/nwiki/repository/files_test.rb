# frozen_string_literal: true

require "test_helper"

module Nwiki
  class Repository
    class FilesTest < Test::Unit::TestCase
      def setup
        repository = Rugged::Repository.new("../nikulog/.git")
        @files = Files.new(repository) # TODO
      end

      def test_each
        assert_equal(Nwiki::Repository::File, @files.first.class)
      end
    end
  end
end
