# frozen_string_literal: true

require "test_helper"

module Nwiki
  class RepositoryTest < Test::Unit::TestCase
    class GivenInvalidRepositoryPath < self
      def setup
        @invalid_repository_path = "invalid_repository_path"
      end

      def test_errortype_is_an_os_error
        assert_raise(Nwiki::Repository::OSError) do
          Nwiki::Repository.new(@invalid_repository_path)
        end
      end

      def test_errormessage_is_failed_to_resolve_path
        assert_raise_message(/\AFailed to resolve path/) do
          Nwiki::Repository.new(@invalid_repository_path)
        end
      end
    end

    class GivenValidRepositoryPath < self
      def setup
        @valid_repository_path = "../nikulog/.git" # TODO
        @repository = Nwiki::Repository.new(@valid_repository_path)
      end

      def test_type_is_a_nwiki_repository
        assert_equal(@repository.class, Nwiki::Repository)
      end

      def test_files_returns_a_files_class
        assert_equal(@repository.files.class, Nwiki::Repository::Files)
      end
    end
  end
end
