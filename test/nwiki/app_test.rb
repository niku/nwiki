# frozen_string_literal: true

require "test_helper"

module Nwiki
  class AppTest < Test::Unit::TestCase
    def setup
      env = {}
      stub(env, :[]).with("NWIKI_ENDPOINT") { "https://niku.name/" }
      stub(env, :[]).with("NWIKI_SITE_NAME") { "ヽ（´・肉・｀）ノログ" }
      stub(env, :[]).with("NWIKI_TAGLINE") { "How do we fighting without fighting?" }
      stub(env, :[]).with("NWIKI_GA_TRACKING_ID") { "UA-12345678-1" }
      config = Config.fetch_from_environment_variable(env)

      repository_path = "../nikulog/.git" # TODO
      repository = Nwiki::Repository.new(repository_path)
      output_directory = Dir.mktmpdir
      @app = App.new(config, repository, output_directory)
    end

    def test_run
      # TODO
      # assert(@app.run)
    end
  end
end
