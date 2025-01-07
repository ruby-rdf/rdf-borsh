Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = "rdf-borsh"
  gem.homepage           = "https://github.com/ruby-rdf/rdf-borsh"
  gem.license            = "Unlicense"
  gem.summary            = "RDF/Borsh for Ruby"
  gem.description        = "An RDF.rb extension for encoding and decoding RDF knowledge graphs in the Borsh binary serialization format."
  gem.metadata           = {
    'bug_tracker_uri'   => "https://github.com/ruby-rdf/rdf-borsh/issues",
    'changelog_uri'     => "https://github.com/ruby-rdf/rdf-borsh/blob/master/CHANGES.md",
    'documentation_uri' => "https://github.com/ruby-rdf/rdf-borsh/blob/master/README.md",
    'homepage_uri'      => gem.homepage,
    'source_code_uri'   => "https://github.com/ruby-rdf/rdf-borsh",
  }

  gem.author             = "Arto Bendiken"
  gem.email              = "public-rdf-ruby@w3.org"

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS CHANGES.md README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w()

  gem.required_ruby_version = '>= 3.0' # RDF.rb 3.3
  gem.add_runtime_dependency     'extlz4',     '~> 0.3'
  gem.add_runtime_dependency     'rdf',        '~> 3.3'
  gem.add_runtime_dependency     'sorted_set', '~> 1.0'
  gem.add_development_dependency 'rdf-spec',   '~> 3.3'
  gem.add_development_dependency 'rspec',      '~> 3.12'
  gem.add_development_dependency 'yard' ,      '~> 0.9'
end
