# -*- coding: utf-8 -*-
require 'spec_helper'

module Nwiki
  module Core
    describe Wiki do
      let(:path) { 'spec/examples/sample.git' }
      subject { described_class.new(path) }

      describe '#page' do
        it { subject.find('/foo').should eq Page.new("* Foo\n** Bar\n\n") }
        it { subject.find('/not_exist_page').should be_nil }
        it { subject.find('/1/2/a').should_not be_nil }
        it { subject.find('/日本語ディレクトリ/わたしだ').should_not be_nil }
      end

    end
  end
end
