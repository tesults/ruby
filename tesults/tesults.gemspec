# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tesults/version'

Gem::Specification.new do |spec|
  spec.name          = "tesults"
  spec.version       = "1.1.0"
  spec.authors       = ["Tesults"]
  spec.email         = ["support@tesults.com"]

  spec.summary       = "Tesults API library."
  spec.description   = "Tesults API library for uploading test results to Tesults in your Ruby application."
  spec.homepage      = "https://www.tesults.com"
  spec.files         = ["lib/tesults.rb"]
  spec.add_development_dependency 'aws-sdk'
  spec.add_runtime_dependency 'aws-sdk'
  spec.license       = "MIT"
end
