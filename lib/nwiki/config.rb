# frozen_string_literal: true

module Nwiki
  class Config < Struct.new(:endpoint, :site_name, :tagline, :ga_tracking_id)
    class << self
      def fetch_from_environment_variable(env = ENV)
        new(URI.parse(env["NWIKI_ENDPOINT"]), env["NWIKI_SITE_NAME"], env["NWIKI_TAGLINE"], env["NWIKI_GA_TRACKING_ID"])
      end
    end
  end
end
