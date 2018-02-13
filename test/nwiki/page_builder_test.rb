# frozen_string_literal: true

require "test_helper"

module Nwiki
  class PageBuilderTest < Test::Unit::TestCase
    def setup
      @config = Object.new
      @html_metadata = Object.new
      @html_metalink = Object.new
      @page_builder = PageBuilder.new(@config, @html_metadata, @html_metalink)
    end

    def test_escape_path
      assert_equal("2011/07/02/Ruby%E5%8B%89%E5%BC%B7%E4%BC%9A%40%E6%9C%AD%E5%B9%8C-18.org",
                   PageBuilder.escape("2011/07/02/Ruby勉強会@札幌-18.org"))
    end

    def test_description
      stub(@html_metadata).description { "orgファイルを元にライブラリを作る方法と苦労" }
      assert_equal("orgファイルを元にライブラリを作る方法と苦労", @page_builder.description)
    end

    def test_url
      stub(@config).endpoint { URI.parse("https://niku.name/") }
      stub(@html_metadata).url { "2018/01/29/nwikiを新しくした.org" }
      assert_equal("https://niku.name/2018/01/29/nwiki%E3%82%92%E6%96%B0%E3%81%97%E3%81%8F%E3%81%97%E3%81%9F.html", @page_builder.url)
    end

    def test_image_url
      stub(@config).endpoint { URI.parse("https://niku.name/") }
      stub(@html_metadata).image_url { "2018/01/29/eyecatch.jpg" }
      assert_equal("https://niku.name/2018/01/29/eyecatch.jpg", @page_builder.image_url)
    end

    def test_image_url_if_nil
      stub(@config).endpoint { URI.parse("https://niku.name/") }
      stub(@html_metadata).image_url { nil }
      assert_equal(nil, @page_builder.image_url)
    end

    def test_title
      stub(@html_metadata).title { "nwikiを新しくした" }
      assert_equal("nwikiを新しくした", @page_builder.title)
    end

    def test_site_name
      stub(@config).site_name { "ヽ（´・肉・｀）ノログ" }
      assert_equal("ヽ（´・肉・｀）ノログ", @page_builder.site_name)
    end

    def test_tagline
      stub(@config).tagline { "How do we fight without fighting?" }
      assert_equal("How do we fight without fighting?", @page_builder.tagline)
    end

    def test_ga_tracking_id
      stub(@config).ga_tracking_id { "UA-26456277-1" }
      assert_equal("UA-26456277-1", @page_builder.ga_tracking_id)
    end

    def test_prev_of
      stub(@config).endpoint { URI.parse("https://niku.name/") }
      stub(@html_metadata).url { "2018/01/29/nwikiを新しくした.org" }
      stub(@html_metalink).prev_of("2018/01/29/nwikiを新しくした.org") { "2018/01/28/nwikiを改良している.org" }

      assert_equal("https://niku.name/2018/01/28/nwiki%E3%82%92%E6%94%B9%E8%89%AF%E3%81%97%E3%81%A6%E3%81%84%E3%82%8B.html", @page_builder.prev_of)
    end

    def test_next_of
      stub(@config).endpoint { URI.parse("https://niku.name/") }
      stub(@html_metadata).url { "2018/01/29/nwikiを新しくした.org" }
      stub(@html_metalink).next_of("2018/01/29/nwikiを新しくした.org") { "2018/01/30/雪がすごい.org" }

      assert_equal("https://niku.name/2018/01/30/%E9%9B%AA%E3%81%8C%E3%81%99%E3%81%94%E3%81%84.html", @page_builder.next_of)
    end

    def test_linked_from
      assert_equal([], @page_builder.linked_from)
    end
  end
end
