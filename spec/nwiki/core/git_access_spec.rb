# -*- coding: utf-8 -*-
require 'spec_helper'

module Nwiki
  module Core
    describe GitAccess do
      let(:path) { 'spec/examples/sample.git' }

      subject { described_class.new(path) }

      describe '#tree' do
        let(:ref) { '63c0856958172223da3309e653f837a3485be4ae' }

        it { subject.tree(ref).should have_at_least(1).blob_entries }
      end
    end

    describe NewGitAccess do
      let(:path) { 'spec/examples/sample.git' }

      subject { described_class.new(path) }

      describe '#title' do
        it { expect(subject.title).to eq 'ヽ（´・肉・｀）ノログ' }
      end
    end
  end
end
