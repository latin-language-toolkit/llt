source 'https://rubygems.org'

# Specify your gem's dependencies in llt-tokenizer.gemspec
gemspec

gem 'coveralls', require: false

gem 'llt-core', git: 'git://github.com/latin-language-toolkit/llt-core.git'
gem 'llt-constants', git: 'git://github.com/latin-language-toolkit/llt-constants.git'
gem 'llt-db_handler', git: 'git://github.com/latin-language-toolkit/llt-db_handler.git'
gem 'llt-helpers', git: 'git://github.com/latin-language-toolkit/llt-helpers.git'
gem 'llt-logger', git: 'git://github.com/latin-language-toolkit/llt-logger.git'
gem 'llt-review', git: 'git://github.com/latin-language-toolkit/llt-review.git'
gem 'llt-segmenter', git: 'git://github.com/latin-language-toolkit/llt-segmenter.git'
gem 'llt-tei_handler', git: 'git://github.com/latin-language-toolkit/llt-tei_handler.git'
gem 'llt-tokenizer', git: 'git://github.com/latin-language-toolkit/llt-tokenizer.git'

# Dependencies of db_handler
gem 'llt-core_extensions', git: 'git://github.com/latin-language-toolkit/llt-core_extensions.git'
gem 'llt-form_builder', git: 'git://github.com/latin-language-toolkit/llt-form_builder.git'

platform :ruby do
  gem 'pg'
end

platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'nokogiri' # needed by llt-review
  gem 'jruby-httpclient'
end

gem 'array_scanner'
