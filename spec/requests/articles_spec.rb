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

      describe 'GET /' do
        let(:path) { '/' }

        pending do 'not implement yet'
        it { subject.should be_ok }
        it { subject.should match %r!\bfoo\b! }
        it { subject.should match %r!\b1\b! }
        it { subject.should match %r!\b日本語ディレクトリ\b! }
        end
      end

      describe 'GET /foo' do
        let(:path) { '/foo' }

        pending do 'not implement yet'
        it { subject.should be_ok }
        it { subject.should match %r!<h2[^>]*>Foo</h2>! }
        it { subject.should match %r!<h3[^>]*>Bar</h3>! }
        end
      end

      describe 'GET /icon.png' do
        let(:path) { '/icon.png' }
        it { subject.should be_ok }
        it { subject['Content-Type'].should eq 'image/png' }
      end

      describe 'GET /1/2/' do
        let(:path) { '/1/2/' }

        pending do 'not implement yet'
        it { subject.should be_ok }
        it { subject.should match %r!\ba\b! }
        it { subject.should match %r!\bb\b! }
        end
      end

      describe 'GET /日本語ディレクトリ/' do
        let(:path) { URI.encode '/日本語ディレクトリ/' }

        pending do 'not implement yet'
        it { subject.should be_ok }
        it { subject.should match %r!<h2[^>]*>わたしだ</h2>! }
        end
      end

      describe 'GET /日本語ディレクトリ/わたしだ' do
        let(:path) { URI.encode '/日本語ディレクトリ/わたしだ' }

        it { subject.should be_ok }
        it { subject.body.should match %r!<h2[^>]*>お前だったのか</h2>! }
        it { subject.body.should match %r!<h3[^>]*>気づかなかったな</h3>! }
      end
    end
  end
end
