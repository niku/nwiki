# -*- coding: utf-8 -*-
require 'spec_helper'

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

      context 'GET /articles' do
        let(:path) { '/articles/' }

        it { subject.should be_ok }
        it { subject.should match %r!\bfoo\b! }
        it { subject.should match %r!\b1\b! }
        it { subject.should match %r!\b日本語ディレクトリ\b! }
      end

      context 'GET /articles.xml' do
        let(:path) { '/articles.xml' }

        it { subject.should be_ok }
        it { subject['Content-Type'].should eq 'application/atom+xml; charset=UTF-8' }

        describe 'response body' do
          subject { RSS::Parser.parse(last_response.body) }
          it { expect { subject }.to_not raise_error }
          it { should_not be_nil }
          it { subject.link.href.should eq 'http://example.org/articles.xml' }
          it { subject.title.content.should eq 'ヽ（´・肉・｀）ノログ' }
          it { subject.subtitle.content.should eq 'Example Site' }
          it { subject.author.name.content.should eq 'Bob' }
          it { subject.date.should eq Time.parse('2014-02-06') }
          it { subject.id.content.should eq '1' }
          it { subject.items.first.link.href.should eq 'http://example.com/article.html' }
          it { subject.items.first.title.content.should eq "Sample Article" }
          it { subject.items.first.date.should eq Time.parse('2004/11/1 10:10') }
        end

      end


      context 'GET /articles/foo' do
        let(:path) { '/articles/foo' }

        it { subject.should be_ok }
        it { subject.should match %r!<h2[^>]*>Foo</h2>! }
        it { subject.should match %r!<h3[^>]*>Bar</h3>! }
      end

      context 'GET /articles/icon.png' do
        let(:path) { '/articles/icon.png' }
        it { subject.should be_ok }
        it { subject['Content-Type'].should eq 'image/png' }
      end

      context 'GET /articles/1/2/' do
        let(:path) { '/articles/1/2/' }

        pending do 'not implement yet'
          it { subject.should be_ok }
          it { subject.should match %r!\ba\b! }
          it { subject.should match %r!\bb\b! }
        end
      end

      context 'GET /articles/日本語ディレクトリ/' do
        let(:path) { URI.encode '/articles/日本語ディレクトリ/' }

        pending do 'not implement yet'
          it { subject.should be_ok }
          it { subject.should match %r!<h2[^>]*>わたしだ</h2>! }
        end
      end

      context 'GET /articles/日本語ディレクトリ/わたしだ' do
        let(:path) { URI.encode '/articles/日本語ディレクトリ/わたしだ' }

        it { subject.should be_ok }
        it { subject.body.should match %r!<h2[^>]*>お前だったのか</h2>! }
        it { subject.body.should match %r!<h3[^>]*>気づかなかったな</h3>! }
      end
    end
  end
end
