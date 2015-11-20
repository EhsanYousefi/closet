# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'closet/version'

Gem::Specification.new do |spec|
  spec.name          = "closet"
  spec.version       = Closet::VERSION
  spec.authors       = ["Ehsan Yousefi"]
  spec.email         = ["ehsan.yousefi@live.com"]

  spec.summary       = %q{Closet let you bury your records instead of killing them.}
  spec.description   = %q{Closet let you bury your records instead of killing them. Data is valuable even thoes you think worthless. Closet helps you bury/hide your records in closet, and restore them whenever you want. Colest only works with ActiveRecord(Mongoid will support in near future) }
  spec.homepage      = "https://github.com/EhsanYousefi/closet"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-mocks", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "factory_girl", "~> 4.0"
  spec.add_development_dependency "database_cleaner", "~> 1.0"


  spec.add_dependency "activerecord", "~> 4.0"

end
