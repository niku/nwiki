# -*- coding: utf-8 -*-
require 'spec_helper'

module Nwiki
  module Core
    describe Wiki do
      let(:path) { 'spec/examples/sample.git' }
      subject { described_class.new(path) }

      describe '.parser' do
        it { described_class.parser.should eq Orgmode::Parser }
      end

      describe '.canonicalize_path' do
        it { described_class.canonicalize_path('/foo/bar/').should eq 'foo/bar/' }
        it { described_class.canonicalize_path('/%E6%97%A5%E6%9C%AC%E8%AA%9E').should eq '日本語' }
      end

      describe '#find' do
        it { subject.find('/foo').should eq Page.new("Foo", "* Foo\n** Bar\n[[icon.png]]\n", Wiki.parser) }
        it { subject.find('/icon.png').should be_kind_of File }
        it { subject.find('/').should be_kind_of Directory }
        it { subject.find('/not_exist_page').should be_nil }
        it { subject.find('/1/2/a').should_not be_nil }
        it { subject.find('/日本語ディレクトリ/わたしだ').should_not be_nil }
      end

      describe '#find_directory' do
        it { subject.find_directory('/').list.should eq \
          Directory.new('/', ["1/2/a", "1/2/b", "foo", "icon.png", "日本語ディレクトリ/わたしだ"]).list
        }
      end

      describe '#name' do
        it { subject.name.should eq 'ヽ（´・肉・｀）ノログ' }
      end

    end
  end
end
