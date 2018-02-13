# frozen_string_literal: true

require "test_helper"

module Nwiki
  class HtmlMetadataTest < Test::Unit::TestCase
    def setup
      html_fragment = Object.new
      stub(html_fragment).read { <<__DOC__ }
<h1>こんにちは</h1>
<p><img src="./greeting.gif" alt="./greeting.gif"></p>
<p>ここにdescriptionが書かれる</p>
<p>ごあいさつでした</p>
__DOC__
      stub(html_fragment).path { Path.new("2011/07/02/", "こんにちは.html") }
      @html_metadata = HtmlMetadata.new(html_fragment)
    end

    def test_url
      assert_equal("2011/07/02/こんにちは.html", @html_metadata.url)
    end

    def test_image_url
      assert_equal("2011/07/02/greeting.gif", @html_metadata.image_url)
    end

    def test_title
      assert_equal("こんにちは", @html_metadata.title)
    end

    def test_description
      assert_equal("ここにdescriptionが書かれる", @html_metadata.description)
    end
  end
end
