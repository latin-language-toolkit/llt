require 'llt'
require 'llt/core/api'
require 'llt/segmenter/api'
require 'llt/tokenizer/api'
require 'sinatra/base'
require 'sinatra/respond_with'

class Api < Sinatra::Base
  helpers LLT::Core::Api::Helpers
  register Sinatra::RespondWith

  get '/segtok' do
    typecast_params!(params)
    text = extract_text(params)
    seg = LLT::Segmenter.new(params)
    tok = LLT::Tokenizer.new(params)
    sentences = seg.segment(text)
    if sentences.any?
      threads_count = (t = ENV['THREADS_FOR_LLT']) ? t.to_i : 4
      threads = []
      sentences.each_slice(slice_size(sentences, threads_count)) do |sliced|
        threads << Thread.new do
          forked_tok = tok.fork_instance
          process_segtok(forked_tok) do
            sliced.each do |sentence|
              forked_tok.tokenize(sentence.to_s, add_to: sentence)
            end
          end
        end
      end
      threads.each(&:join)
    end

    respond_to do |f|
      f.xml { to_xml(sentences, params) }
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
