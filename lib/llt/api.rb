require 'llt'
require 'llt/core/api'
require 'sinatra/base'
require 'sinatra/respond_with'

class Api < Sinatra::Base
  helpers LLT::Core::Api::Helpers
  register Sinatra::RespondWith

  get '/segtok' do
    text = extract_text(params)
    seg = LLT::Segmenter.new(params)
    tok = LLT::Tokenizer.new(params)
    sentences = seg.segment(text)
    if sentences.any?
      threads_count = 4 # use an env var here
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
    size = sentences.size / threads - 1
    size < 0 ? (sentences.size - 1) : size
  end

  def process_segtok(forked_tok)
    if forked_tok.db.type == :prometheus
      StemDatabase::Db.connection_pool.with_connection { yield }
    else
      yield
    end
  end
end
