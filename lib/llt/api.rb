require 'llt'
require 'llt/core/api'
require 'llt/review/api'
require 'llt/segmenter/api'
require 'llt/tokenizer/api'
require 'sinatra/base'
require 'sinatra/respond_with'
require 'cgi'

class Api < Sinatra::Base
  helpers LLT::Core::Api::Helpers
  register LLT::Core::Api::VersionRoutes
  register Sinatra::RespondWith

  post '/segtok' do
    parse_request
  end

  get '/segtok' do
    parse_request
  end

  def parse_request
    typecast_params!(params)
    text = extract_text(params)

    text = preprocess_xml(text, params) if params[:xml]

    seg = LLT::Segmenter.new(params)
    tok = LLT::Tokenizer.new(params)

    # Let's disable threading for now. It breaks the test. Could have just been
    # an update to rack-test or something like that, which caused it.
    # Have to go back in history to see when the error exactly occurs (sadly,
    # Travis wasn't running in this repository...) and maybe use an older
    # version of the causing gem.

    # Unescaping HTML chars: During work on greek segmenter it turned out that
    # the parsed Herodotus xml file returned HTML characters instead of UTF-8,
    # which caused problems in segmenting.
    # CGI.unescapeHTML converts those into UTF-8.
    unescaped_text = CGI.unescapeHTML(text)
    sentences = seg.segment(unescaped_text)
    sentences.each do |sentence|
      tok.tokenize(sentence.to_s, add_to: sentence)
    end
    #if sentences.any?
      #threads_count = (t = ENV['THREADS_FOR_LLT']) ? t.to_i : 4
      #threads = []
      #sentences.each_slice(slice_size(sentences, threads_count)) do |sliced|
        #threads << Thread.new do
          #forked_tok = tok.fork_instance
          #process_segtok(forked_tok) do
            #sliced.each do |sentence|
              #forked_tok.tokenize(sentence.to_s, add_to: sentence)
            #end
          #end
        #end
      #end
      #threads.each(&:join)
    #end

    params.merge!(root: 'llt-segtok') # add info here about the service itself?

    respond_to do |f|
      f.xml { to_xml(sentences, params) }
    end
  end

  add_version_route_for('/segtok', dependencies: %i{ Core Segmenter Tokenizer })

  def preprocess_xml(text, params)
    root = params[:go_to_root]
    nodes_to_remove = params[:remove_node]
    if root || nodes_to_remove
      kws = { root: root, ns: params[:ns] }
      preprocessor = LLT::XmlHandler::PreProcessor.new(text, kws)
      preprocessor.remove_nodes(*nodes_to_remove)
      preprocessor.to_xml
    else
      text
    end
  end

  def slice_size(sentences, threads)
    sent_size = sentences.size
    size = sent_size / threads + 1
    size <= 0 ? sent_size : size
  end

  def process_segtok(tokenizer)
    if tokenizer.db.type == :prometheus
      StemDatabase::Db.connection_pool.with_connection { yield }
      # This should NOT be needed, the block above should solve that.
      # I have no clue why the connections don't close by themselves...
      StemDatabase::Db.connection.close
    else
      yield
    end
  end
end
