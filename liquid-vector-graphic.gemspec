# coding: utf-8
require_relative 'lib/liquid_vector_graphic/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version  = '>= 2.3.1'

  spec.name                   = "liquid-vector-graphic"
  spec.version                = LiquidVectorGraphic::VERSION

  spec.authors                = ["Nic Boie", "JD Guzman", "Tamara Temple"]
  spec.email                  = ["development@bluewaterbrand.com"]

  spec.summary                = "A library to render SVG graphics with Liquid template logic."
  spec.description            = ""
  spec.homepage               = ""

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'locomotivecms-solid', '~> 4.0.1'
  spec.add_runtime_dependency 'activesupport', '>= 4.0.0'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~>0.10"
end
