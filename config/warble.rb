# Disable Rake-environment-task framework detection by uncommenting/setting to false
# Warbler.framework_detection = false

# Warbler web application assembly configuration file
Warbler::Config.new do |config|
  # We are using the gemspec instead, as the Gemfile itself is
  # pointing to edge versions of dependent gems. It also seems
  # that warbler has all kinds of troubles when pulling in gems
  # from git...
  config.bundler = false

  # These gems are jruby only, we cannot include them in the gemspecs, as they
  # would break MRI compatibility.
  config.gems << 'activerecord-jdbcpostgresql-adapter'
  config.gems << 'jruby-httpclient'

  # Set JRuby to run in 2.0 mode.
  config.webxml.jruby.compat.version = "2.0"
end
