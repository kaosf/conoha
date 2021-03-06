# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'conoha/version'

Gem::Specification.new do |spec|
  spec.name          = "conoha"
  spec.version       = ConohaVersion::ITSELF
  spec.authors       = ["ka"]
  spec.email         = ["ka.kaosf@gmail.com"]

  spec.summary       = %q{ConoHa VPS CLI Tool}
  spec.description   = %q{ConoHa VPS CLI Tool}
  spec.homepage      = "https://github.com/kaosf/conoha"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.2"
  spec.add_development_dependency "test-unit-rr", "~> 1.0"
  spec.add_development_dependency "coveralls", "~> 0.8"
  spec.add_development_dependency "guard", "~> 2.13"
  spec.add_development_dependency "guard-minitest", "~> 2.4"
end
