module Nwiki
  class RootIndexBuilderTest < Test::Unit::TestCase
    def setup
      @config = Object.new
      @html_metadata = Object.new
      @root_index_builder = RootIndexBuilder.new(@config, @html_metadata)
    end

    # TODO: test
  end
end
