ENV['RACK_ENV'] = 'test'

require 'spec_helper'
require 'llt/api'
require 'rack/test'

def app
  Api
end

describe "main api" do
  include Rack::Test::Methods

  describe '/segtok' do
    context "with URI as input" do
    end

    let(:text) {{text: "homo mittit. Marcus est."}}
    let(:html_text) {{text: "&#954;&#945;&#953;."}}

    context "with text as input" do
      context "with accept header json" do
        it "segtoks the given text" do
          pending
          get '/segtok', text,
            {"HTTP_ACCEPT" => "application/json"}
          last_response.should be_ok
          response = last_response.body
          parsed_response = JSON.parse(response)
          parsed_response.should have(3).items
        end
      end

      context "with accept header xml" do
        it "segtoks the given text" do
          get '/segtok', text,
            {"HTTP_ACCEPT" => "application/xml"}
          last_response.should be_ok
          body = last_response.body
          body.should =~ /<w n="1">homo<\/w>/
          body.should =~ /<w n="2">mittit<\/w>/
          body.should =~ /<pc n="3">\.<\/pc>/
        end

        it "segtoks the given greek texts with unescaping html entities" do
          get '/segtok', html_text,
            {"HTTP_ACCEPT" => "application/xml"}
          last_response.should be_ok
          body = last_response.body
          body.should =~ /<w n="1">και<\/w>/
          body.should =~ /<pc n="2">\.<\/pc>/
        end

        it "receives params for tokenization and markup" do
          params = {
            indexing: true,
            recursive: true,
            inline: true,
          }.merge(text)

          get '/segtok', params,
            {"HTTP_ACCEPT" => "application/xml"}
          last_response.should be_ok
          body = last_response.body
          body.should =~ /<w s_n="1" n="1">homo<\/w>/
          body.should =~ /<w s_n="1" n="2">mittit<\/w>/
          body.should =~ /<pc s_n="1" n="3">\.<\/pc>/
          body.should =~ /<w s_n="2" n="1">Marcus<\/w>/
          body.should =~ /<w s_n="2" n="2">est<\/w>/
          body.should =~ /<pc s_n="2" n="3">\.<\/pc>/
        end

        it "receives params in post for tokenization and markup" do
          params = {
            indexing: true,
            recursive: true,
            inline: true,
          }.merge(text)

          post '/segtok', params,
            {"HTTP_ACCEPT" => "application/xml"}
          last_response.should be_ok
          body = last_response.body
          body.should =~ /<w s_n="1" n="1">homo<\/w>/
          body.should =~ /<w s_n="1" n="2">mittit<\/w>/
          body.should =~ /<pc s_n="1" n="3">\.<\/pc>/
          body.should =~ /<w s_n="2" n="1">Marcus<\/w>/
          body.should =~ /<w s_n="2" n="2">est<\/w>/
          body.should =~ /<pc s_n="2" n="3">\.<\/pc>/
        end

        it "doesn't break with complex embedded xml elements" do
          txt = { text: 'Arma <l no="1.1"> virumque cano. Troiae </l> qui primus.' }
          params = {
            indexing: true,
            recursive: true,
            inline: true,
            xml: true,
          }.merge(txt)

          get '/segtok', params,
            {"HTTP_ACCEPT" => "application/xml"}
          last_response.should be_ok
          body = last_response.body
          elements = [
            '<w s_n="1" n="1">Arma</w>',
            '<l no="1.1">',
            '<w s_n="1" n="2">-que</w>',
            '<w s_n="1" n="3">virum</w>',
            '<w s_n="1" n="4">cano</w>',
            '<pc s_n="1" n="5">.</pc>',
            '<w s_n="2" n="1">Troiae</w>',
            '</l>',
            '<w s_n="2" n="2">qui</w>',
            '<w s_n="2" n="3">primus</w>',
            '<pc s_n="2" n="4">.</pc>'
          ]

          body.should =~ /#{elements.join}/
        end
      end
    end
  end
end
