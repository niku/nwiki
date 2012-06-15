# -*- coding: utf-8 -*-
require 'spec_helper'

module Nwiki
  describe 'Articles' do
    def app
      Nwiki::Articles.new data_file_directory: 'spec/examples/sample.git', site_title: '肉ログ', file_encoding: 'UTF-8'
    end

    subject { last_response }

    before do
      get path
    end

    describe 'GET /' do
      let(:path) { '/' }

      it { subject.should be_ok }
      it { subject.should match %r!\bfoo\b! }
      it { subject.should match %r!\b1\b! }
      it { subject.should match %r!\b日本語ディレクトリ\b! }
    end

    describe 'GET /foo' do
      let(:path) { '/foo' }

      it { subject.should be_ok }
      it { subject.should match %r!<h2[^>]*>Foo</h2>! }
      it { subject.should match %r!<h3[^>]*>Bar</h3>! }
    end

    describe 'GET /1/2/' do
      let(:path) { '/1/2/' }

      it { subject.should be_ok }
      it { subject.should match %r!\ba\b! }
      it { subject.should match %r!\bb\b! }
    end

    describe 'GET /日本語ディレクトリ/' do
      let(:path) { URI.encode '/日本語ディレクトリ/' }

      it { subject.should be_ok }
      it { subject.should match %r!<h2[^>]*>わたしだ</h2>! }
    end

    describe 'GET /日本語ディレクトリ/わたしだ' do
      let(:path) { URI.encode '/日本語ディレクトリ/わたしだ' }

      it { subject.should be_ok }
      it { subject.should match %r!<h2[^>]*>お前だったのか</h2>! }
      it { subject.should match %r!<h3[^>]*>気づかなかったな</h3>! }
    end
  end
end
