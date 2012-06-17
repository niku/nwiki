require 'spec_helper'

module Nwiki
  module Core
    describe GitAccess do
      let(:path) { 'spec/examples/sample.git' }

      describe '#initialize' do
        it { expect { described_class.new(path) }.to_not raise_error }
      end
    end
  end
end
