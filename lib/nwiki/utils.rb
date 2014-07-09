module Nwiki
  module Utils
    def self.page_title path
      path.empty? ? '' : "#{path.gsub(/\.org$/, '').gsub(/^\//, '')} - "
    end
  end
end
