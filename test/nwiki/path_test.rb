# frozen_string_literal: true

require "test_helper"

module Nwiki
  class PathTest < Test::Unit::TestCase
    class GivenNestedPath < self
      def setup
        @path = Path.new("2011/07/02/", "Ruby勉強会@札幌-18.org")
      end

      def test_dirname
        assert_equal("2011/07/02/", @path.dirname)
      end

      def test_basename
        assert_equal("Ruby勉強会@札幌-18.org", @path.basename)
      end

      def test_name
        assert_equal("2011/07/02/Ruby勉強会@札幌-18.org", @path.name)
      end

      def test_extname
        assert_equal(".org", @path.extname)
      end

      def test_escaped_dirname
        assert_equal("2011/07/02/", @path.escaped_dirname)
      end

      def test_escaped_basename
        assert_equal("Ruby%E5%8B%89%E5%BC%B7%E4%BC%9A%40%E6%9C%AD%E5%B9%8C-18.org", @path.escaped_basename)
      end

      def test_escaped_name
        assert_equal("2011/07/02/Ruby%E5%8B%89%E5%BC%B7%E4%BC%9A%40%E6%9C%AD%E5%B9%8C-18.org", @path.escaped_name)
      end

      def test_escaped_extname
        assert_equal(".org", @path.extname)
      end
    end

    class GivenFlatPath < self
      def setup
        @path = Path.new("", "Ruby勉強会@札幌-18.org")
      end

      def test_dirname
        assert_equal("", @path.dirname)
      end

      def test_basename
        assert_equal("Ruby勉強会@札幌-18.org", @path.basename)
      end

      def test_name
        assert_equal("Ruby勉強会@札幌-18.org", @path.name)
      end

      def test_extname
        assert_equal(".org", @path.extname)
      end

      def test_escaped_dirname
        assert_equal("", @path.escaped_dirname)
      end

      def test_escaped_basename
        assert_equal("Ruby%E5%8B%89%E5%BC%B7%E4%BC%9A%40%E6%9C%AD%E5%B9%8C-18.org", @path.escaped_basename)
      end

      def test_escaped_name
        assert_equal("Ruby%E5%8B%89%E5%BC%B7%E4%BC%9A%40%E6%9C%AD%E5%B9%8C-18.org", @path.escaped_name)
      end

      def test_escaped_extname
        assert_equal(".org", @path.extname)
      end
    end
  end
end
