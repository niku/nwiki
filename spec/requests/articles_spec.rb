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

      context 'GET /' do
        let(:path) { '/' }

        it { expect(subject).to be_ok }
        it { expect(subject).to match %r!\bヽ（´・肉・｀）ノログ\b! }
        it { expect(subject).to match %r!\bHow do we fighting without fighting?\b! }
      end

      context 'GET /articles' do
        let(:path) { '/articles/' }

        it { expect(subject).to be_ok }
        it { expect(subject).to match %r!\bfoo\b! }
        it { expect(subject).to match %r!\b1\b! }
        it { expect(subject).to match %r!\b日本語ディレクトリ\b! }
      end

      context 'GET /articles.xml' do
        let(:path) { '/articles.xml' }

        it { expect(subject).to be_ok }
        it { expect(subject['Content-Type']).to eq 'application/atom+xml; charset=UTF-8' }

        describe 'response body' do
          subject { RSS::Parser.parse(last_response.body) }
          it { expect { subject }.to_not raise_error }
          it { is_expected.to_not be_nil }
          it { expect(subject.link.href).to eq 'http://example.org/articles.xml' }
          it { expect(subject.title.content).to eq 'ヽ（´・肉・｀）ノログ' }
          it { expect(subject.subtitle.content).to eq 'How do we fighting without fighting?' }
          it { expect(subject.author.name.content).to eq 'niku' }
          it { expect(subject.date).to eq Time.parse('2012-08-09 20:15:07 +0900') }
          it { expect(subject.id.content).to eq 'http://example.org/articles.xml' }
          it { expect(subject.items.first.link.href).to eq 'http://example.org/articles/foo' }
          it { expect(subject.items.first.title.content).to eq 'foo' }
          it { expect(subject.items.first.date).to eq Time.parse('2012-08-09 20:15:07 +0900') }
        end

      end


      context 'GET /articles/foo' do
        let(:path) { '/articles/foo' }

        it { expect(subject).to be_ok }
        it { expect(subject).to match %r!<title[^>]*>foo - ヽ（´・肉・｀）ノログ</title>!}
        it { expect(subject).to match %r!<h2[^>]*>Foo</h2>! }
        it { expect(subject).to match %r!<h3[^>]*>Bar</h3>! }
      end

      context 'GET /articles/icon.png' do
        let(:path) { '/articles/icon.png' }
        it { expect(subject).to be_ok }
        it { expect(subject['Content-Type']).to eq 'image/png' }
      end

      context 'GET /articles/1/2/' do
        let(:path) { '/articles/1/2/' }

        pending do 'not implement yet'
          it { expect(subject).to be_ok }
          it { expect(subject).to match %r!\ba\b! }
          it { expect(subject).to match %r!\bb\b! }
        end
      end

      context 'GET /articles/日本語ディレクトリ/' do
        let(:path) { URI.encode '/articles/日本語ディレクトリ/' }

        pending do 'not implement yet'
          it { expect(subject).to be_ok }
          it { expect(subject).to match %r!<h2[^>]*>わたしだ</h2>! }
        end
      end

      context 'GET /articles/日本語ディレクトリ/わたしだ' do
        let(:path) { URI.encode '/articles/日本語ディレクトリ/わたしだ' }

        it { expect(subject).to be_ok }
        it { expect(subject.body).to match %r!<title[^>]*>日本語ディレクトリ/わたしだ - ヽ（´・肉・｀）ノログ</title>!}
        it { expect(subject.body).to match %r!<h2[^>]*>お前だったのか</h2>! }
        it { expect(subject.body).to match %r!<h3[^>]*>気づかなかったな</h3>! }
      end
    end
  end
end
