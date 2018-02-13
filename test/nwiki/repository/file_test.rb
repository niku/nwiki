# frozen_string_literal: true

require "test_helper"

module Nwiki
  class Repository
    class FileTest < Test::Unit::TestCase
      class GivenRoot < self
        def setup
          repository = Rugged::Repository.new("../nikulog/.git")
          root = "2011/07/02/"
          entry = {
            name: "Ruby勉強会@札幌-18.org",
            oid: "24f92bff067eb5c49b4fafbb96bff7ece96b4857",
            filemode: 33188,
            type: :blob
          }
          @file = File.new(repository, root, entry)
        end

        def test_path
          assert_equal("2011/07/02/Ruby勉強会@札幌-18.org", @file.path.name)
        end
      end

      class TopLevel < self
        def setup
          repository = Rugged::Repository.new("../nikulog/.git")
          root = ""
          entry = {
            name: ".travis.yml",
            oid: "fead34d667b75fb658fd010b049ab1724d439b55",
            filemode: 33188,
            type: :blob
          }
          @file = File.new(repository, root, entry)
        end

        def test_path
          assert_equal(".travis.yml", @file.path.name)
        end
      end
    end
  end
end
