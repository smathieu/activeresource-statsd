
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "activeresource/statsd/version"

Gem::Specification.new do |spec|
  spec.name          = "activeresource-statsd"
  spec.version       = Activeresource::Statsd::VERSION
  spec.authors       = ["Simon Mathieu"]
  spec.email         = ["simon.mathieu@shopify.com"]

  spec.summary       = %q{Push activeresource metrics to Statsd}
  spec.homepage      = "https://github.com/Shopify/activeresource-statsd"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activeresource"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "pry-byebug"
end
