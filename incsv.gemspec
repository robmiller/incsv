# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'incsv/version'

Gem::Specification.new do |spec|
  spec.name          = "incsv"
  spec.version       = InCSV::VERSION
  spec.authors       = ["Rob Miller"]
  spec.email         = ["rob@bigfish.co.uk"]

  spec.summary       = %q{A tool for interrogating CSV data using SQLite and Sequel.}
  spec.description   = %q{Loads a CSV file into an SQLite database automatically, dropping you into a Ruby shell that allows you to explore the data within.}
  spec.homepage      = "https://github.com/robmiller/incsv"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "thor", "~> 0.19.1"
  spec.add_runtime_dependency "pry", "~> 0.10"
  spec.add_runtime_dependency "sqlite3", "~> 1.3"
  spec.add_runtime_dependency "sequel", "~> 4.31"
end
