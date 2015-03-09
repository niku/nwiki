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
end
