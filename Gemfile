source 'https://rubygems.org'

# Specify your gem's dependencies in llt-tokenizer.gemspec
gemspec

gem 'coveralls', require: false

gem 'llt-core', git: 'https://github.com/latin-language-toolkit/llt-core.git'
gem 'llt-constants', git: 'https://github.com/latin-language-toolkit/llt-constants.git'
gem 'llt-db_handler', git: 'https://github.com/latin-language-toolkit/llt-db_handler.git'
gem 'llt-helpers', git: 'https://github.com/latin-language-toolkit/llt-helpers.git'
gem 'llt-logger', git: 'https://github.com/latin-language-toolkit/llt-logger.git'
gem 'llt-segmenter', git: 'https://github.com/latin-language-toolkit/llt-segmenter.git'
gem 'llt-tokenizer', git: 'https://github.com/latin-language-toolkit/llt-tokenizer.git'

# Dependencies of db_handler
gem 'llt-core_extensions', git: 'https://github.com/latin-language-toolkit/llt-core_extensions.git'
gem 'llt-form_builder', git: 'https://github.com/latin-language-toolkit/llt-form_builder.git'

platform :ruby do
  gem 'pg'
end

platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'jruby-httpclient'
end

gem 'pry'
gem 'array_scanner'
