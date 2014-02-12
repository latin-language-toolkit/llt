# Disable Rake-environment-task framework detection by uncommenting/setting to false
# Warbler.framework_detection = false

# Warbler web application assembly configuration file
Warbler::Config.new do |config|
  # This is finally working with the advent of warbler version 1.4.1
  config.bundler = true

  # Set JRuby to run in 2.0 mode.
  config.webxml.jruby.compat.version = "2.0"
end
