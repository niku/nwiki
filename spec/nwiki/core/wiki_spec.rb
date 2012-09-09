# -*- coding: utf-8 -*-
require 'spec_helper'

module Nwiki
  module Core
    describe Wiki do
      let(:path) { 'spec/examples/sample.git' }
      subject { described_class.new(path) }

      describe '.canonicalize_path' do
        it { described_class.canonicalize_path('/foo').should eq 'foo' }
        it { described_class.canonicalize_path('/日本語').should eq '日本語' }
      end

      describe '#find' do
        it { subject.find('/foo').should eq Page.new("Foo", "* Foo\n** Bar\n[[icon.png]]\n", Wiki.parser) }
        it { subject.find('/icon.png').should be_kind_of File }
        it { subject.find('/not_exist_page').should be_nil }
        it { subject.find('/1/2/a').should_not be_nil }
        it { subject.find('/日本語ディレクトリ/わたしだ').should_not be_nil }
      end

      describe '#name' do
        it { subject.name.should eq 'ヽ（´・肉・｀）ノログ' }
      end
    end
  end
end
