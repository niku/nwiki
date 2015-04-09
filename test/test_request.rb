require "nwiki"
require "test/unit"
require "rack/test"

class RequestTest < Test::Unit::TestCase
  include ::Rack::Test::Methods

  def app
    Nwiki::Frontend::App.new "spec/examples/sample.git"
  end

  sub_test_case %Q(Get "/") do
    setup do
      get "/"
    end

    test "response is ok" do
      assert last_response.ok?
    end

    test "includes title" do
      title = "ヽ（´・肉・｀）ノログ"
      assert do
        last_response.body.include? title
      end
    end

    test "includes subtitle" do
      subtitle = "How do we fighting without fighting?"
      assert do
        last_response.body.include? subtitle
      end
    end
  end

  sub_test_case %Q(Get "/articles/") do
    setup do
      get "/articles/"
    end

    test "response is ok" do
      assert do
        last_response.ok?
      end
    end

    test "charset is UTF-8" do
      assert do
        last_response["Content-Type"].include? "charset=UTF-8"
      end
    end

    data("contains foo" => "foo",
         "contains 1" => "1",
         "contains 日本語ディレクトリ" => "日本語ディレクトリ")
    def test_body_include?(data)
      expected = data
      assert do
        last_response.body.include? expected
      end
    end
  end
end
