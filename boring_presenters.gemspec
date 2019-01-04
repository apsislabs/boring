lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'boring_presenters/version'

Gem::Specification.new do |spec|
  spec.name          = 'boring_presenters'
  spec.version       = Boring::VERSION
  spec.authors       = ['Wyatt Kirby', "Noah Callaway"]
  spec.email         = ['wyatt@apsis.io', "noah@apsis.io"]

  spec.summary       = 'A boring presentation layer.'
  spec.homepage      = 'http://www.apsis.io'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '~> 2.1'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
