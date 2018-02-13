# frozen_string_literal: true

require "test_helper"

module Nwiki
  class HtmlMetalinkTest < Test::Unit::TestCase
    def setup
      html_fragment_0 = Object.new
      stub(html_fragment_0).path { Path.new("2017/02/14/", "バレンタイン.html") }
      html_fragment_1 = Object.new
      stub(html_fragment_1).path { Path.new("2017/03/03/", "桃の節句.html") }
      html_fragment_2 = Object.new
      stub(html_fragment_2).path { Path.new("topics/", "greeting.html") }
      html_fragment_3 = Object.new
      stub(html_fragment_3).path { Path.new("2016/12/25/", "クリスマス.html") }
      html_fragment_4 = Object.new
      stub(html_fragment_4).path { Path.new("2017/01/01/", "元旦.html") }
      html_fragment_5 = Object.new
      stub(html_fragment_5).path { Path.new("topics/", "reviews.html") }
      html_fragments = [
        html_fragment_0,
        html_fragment_1,
        html_fragment_2,
        html_fragment_3,
        html_fragment_4,
        html_fragment_5
      ]
      @html_metalink = HtmlMetalink.new(html_fragments)
    end

    def test_prev_of
      assert_equal(nil, @html_metalink.prev_of("2016/12/25/クリスマス.html"))
      assert_equal("2017/02/14/バレンタイン.html", @html_metalink.prev_of("2017/03/03/桃の節句.html"))
      assert_equal(nil, @html_metalink.prev_of("topics/greeting.html"))
      assert_equal("topics/greeting.html", @html_metalink.prev_of("topics/reviews.html"))
    end

    def test_next_of
      assert_equal("2017/01/01/元旦.html", @html_metalink.next_of("2016/12/25/クリスマス.html"))
      assert_equal(nil, @html_metalink.next_of("2017/03/03/桃の節句.html"))
      assert_equal("topics/reviews.html", @html_metalink.next_of("topics/greeting.html"))
      assert_equal(nil, @html_metalink.next_of("topics/reviews.html"))
    end

    def test_links_for
      assert_equal([], @html_metalink.links_for("2017/02/14/バレンタイン.html"))
    end
  end
end
