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
          pending
          get '/segtok', text,
            {"HTTP_ACCEPT" => "application/xml"}
          last_response.should be_ok
          body = last_response.body
          body.should =~ /<w>homo<\/w>/
          body.should =~ /<w>mittit<\/w>/
          body.should =~ /<pc>\.<\/pc>/
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
      end
    end
  end
end
