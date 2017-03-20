# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tesults/version'

Gem::Specification.new do |spec|
  spec.name          = "tesults"
  spec.version       = "1.0.1"
  spec.authors       = ["Tesults"]
  spec.email         = ["support@tesults.com"]

  spec.summary       = "Tesults API library."
  spec.description   = "Tesults is a test automation results reporting service. This API library makes it easier to upload your test results from your Ruby application."
  spec.homepage      = "https://www.tesults.com"
  spec.files         = ["lib/tesults.rb"]
  spec.license       = "MIT"
end
