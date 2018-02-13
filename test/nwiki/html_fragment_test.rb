# frozen_string_literal: true

require "test_helper"

module Nwiki
  class HtmlFragmentTest < Test::Unit::TestCase
    def setup
      file = Object.new
      stub(file).read { <<__EOD__ }
* こんにちは

- [[http://example.com/something.org][フルパスリンク]]
- [[org_link.org][orgリンク]]
- [[other_link.html][別リンク]]
__EOD__
      @html_fragment = HtmlFragment.new(file)
    end

    def test_read
      assert_equal("<h1>こんにちは</h1>", @html_fragment.read.lines.first.chomp)
    end
  end
end
