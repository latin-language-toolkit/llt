# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'llt/version'

Gem::Specification.new do |spec|
  spec.name          = "llt"
  spec.version       = LLT::VERSION
  spec.authors       = ["LFDM, christof, lichtr"]
  spec.email         = ["1986gh@gmail.com"]
  spec.description   = %q{LLT meta gem}
  spec.summary       = %q{LLT meta gem}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov", "~> 0.7"
  spec.add_dependency "llt-segmenter"
  spec.add_dependency "llt-tokenizer"
  spec.add_dependency "thor"
end
