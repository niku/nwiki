# -*- coding: utf-8 -*-
require 'spec_helper'

module Nwiki
  module Core
    describe Wiki do
      let(:path) { 'spec/examples/sample.git' }
      subject { described_class.new(path) }

      describe '.parser' do
        it { expect(described_class.parser).to eq Orgmode::Parser }
      end

      describe '.canonicalize_path' do
        it { expect(described_class.canonicalize_path('/foo/bar/')).to eq 'foo/bar/' }
        it { expect(described_class.canonicalize_path('/%E6%97%A5%E6%9C%AC%E8%AA%9E')).to eq '日本語' }
      end

      describe '#find' do
        it { expect(subject.find('/foo')).to eq Page.new("Foo", "* Foo\n** Bar\n[[icon.png]]\n", Wiki.parser) }
        it { expect(subject.find('/icon.png')).to be_kind_of File }
        it { expect(subject.find('/')).to be_kind_of Directory }
        it { expect(subject.find('/not_exist_page')).to be_nil }
        it { expect(subject.find('/1/2/a')).to_not be_nil }
        it { expect(subject.find('/日本語ディレクトリ/わたしだ')).to_not be_nil }
      end

      describe '#find_directory' do
        it { expect(subject.find_directory('/').list).to eq \
          ["foo", "日本語ディレクトリ/わたしだ", "1/2/a", "1/2/b"]
        }
      end

      describe '#title' do
        it { expect(subject.title).to eq 'ヽ（´・肉・｀）ノログ' }
      end

      describe '#subtitle' do
        it { expect(subject.subtitle).to eq 'How do we fighting without fighting?' }
      end

      describe '#author' do
        it { (expect(subject.author)).to eq 'niku' }
      end
    end
  end
end
