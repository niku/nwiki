# -*- coding: utf-8 -*-
require 'spec_helper'
require 'rss'

module Nwiki
  module Frontend
    describe do
      def app
        App.new 'spec/examples/sample.git'
      end

      subject { last_response }

      before do
        get path
      end

      describe 'GET /articles' do
        let(:path) { '/articles/' }

        it { subject.should be_ok }
        it { subject.should match %r!\bfoo\b! }
        it { subject.should match %r!\b1\b! }
        it { subject.should match %r!\b日本語ディレクトリ\b! }
      end

      describe 'GET /articles.xml' do
        let(:path) { '/articles.xml' }

        it { subject.should be_ok }
        it { subject['Content-Type'].should eq 'application/atom+xml; charset=UTF-8' }
        it { expect { RSS::Parser.parse(subject.body) }.to_not raise_error }
      end


      describe 'GET /articles/foo' do
        let(:path) { '/articles/foo' }

        it { subject.should be_ok }
        it { subject.should match %r!<h2[^>]*>Foo</h2>! }
        it { subject.should match %r!<h3[^>]*>Bar</h3>! }
      end

      describe 'GET /articles/icon.png' do
        let(:path) { '/articles/icon.png' }
        it { subject.should be_ok }
        it { subject['Content-Type'].should eq 'image/png' }
      end

      describe 'GET /articles/1/2/' do
        let(:path) { '/articles/1/2/' }

        pending do 'not implement yet'
          it { subject.should be_ok }
          it { subject.should match %r!\ba\b! }
          it { subject.should match %r!\bb\b! }
        end
      end

      describe 'GET /articles/日本語ディレクトリ/' do
        let(:path) { URI.encode '/articles/日本語ディレクトリ/' }

        pending do 'not implement yet'
          it { subject.should be_ok }
          it { subject.should match %r!<h2[^>]*>わたしだ</h2>! }
        end
      end

      describe 'GET /articles/日本語ディレクトリ/わたしだ' do
        let(:path) { URI.encode '/articles/日本語ディレクトリ/わたしだ' }

        it { subject.should be_ok }
        it { subject.body.should match %r!<h2[^>]*>お前だったのか</h2>! }
        it { subject.body.should match %r!<h3[^>]*>気づかなかったな</h3>! }
      end
    end
  end
end
