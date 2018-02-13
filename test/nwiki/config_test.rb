# frozen_string_literal: true

require "test_helper"

module Nwiki
  class ConfigTest < Test::Unit::TestCase
    def test_fetch_from_environment_variable
      endpoint = "https://niku.name/"
      site_name = "ヽ（´・肉・｀）ノログ"
      tagline = "How do we fighting without fighting?"
      ga_tracking_id = "UA-26456277-1"

      env = {}
      stub(env, :[]).with("NWIKI_ENDPOINT") { endpoint }
      stub(env, :[]).with("NWIKI_SITE_NAME") { site_name }
      stub(env, :[]).with("NWIKI_TAGLINE") { tagline }
      stub(env, :[]).with("NWIKI_GA_TRACKING_ID") { ga_tracking_id }

      config = Config.fetch_from_environment_variable(env)
      assert_equal(URI.parse(endpoint), config.endpoint)
      assert_equal(site_name, config.site_name)
      assert_equal(tagline, config.tagline)
      assert_equal(ga_tracking_id, config.ga_tracking_id)
    end
  end
end
