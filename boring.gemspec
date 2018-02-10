
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "boring/version"

Gem::Specification.new do |spec|
  spec.name          = "boring"
  spec.version       = Boring::VERSION
  spec.authors       = ["Wyatt Kirby", "Noah Callaway"]
  spec.email         = ["wyatt@apsis.io", "noah@apsis.io"]

  spec.summary       = %q{A boring presentation layer.}
  spec.homepage      = "http://www.apsis.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
