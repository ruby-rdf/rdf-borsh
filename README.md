# RDF/Borsh for Ruby

[![License](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://unlicense.org)
[![Compatibility](https://img.shields.io/badge/ruby-3.0%2B-blue)](https://rubygems.org/gems/rdf-borsh)
[![Package](https://img.shields.io/gem/v/rdf-borsh)](https://rubygems.org/gems/rdf-borsh)

A Ruby library for encoding and decoding RDF data using the [Borsh]
binary serialization format.

[Borsh]: https://borsh.io

## 🛠️ Prerequisites

- [Ruby](https://ruby-lang.org) 3.0+

## ⬇️ Installation

### Installation via RubyGems

```bash
gem install rdf-borsh
```

## 👉 Examples

### Importing the library

```ruby
require 'rdf/borsh'

include RDF
```

### Serializing an RDF graph into an RDF/Borsh file

```ruby
RDF::Borsh::Writer.open("mygraph.rdfb") do |writer|
  writer << [RDF::URI("https://rubygems.org/gems/rdf-borsh"), RDFS.label, "RDF/Borsh for Ruby"]
end
```

### Parsing an RDF graph from an RDF/Borsh file

```ruby
graph = RDF::Graph.load("mygraph.rdfb")
graph.to_a
```

### Parsing an RDF/Borsh dataset from standard input

```ruby
RDF::Borsh::Reader.new($stdin).to_a
```

## 👨‍💻 Development

```bash
git clone https://github.com/ruby-rdf/rdf-borsh.git
```

- - -

[![Share on Twitter](https://img.shields.io/badge/share%20on-twitter-03A9F4?logo=twitter)](https://twitter.com/share?url=https://github.com/ruby-rdf/rdf-borsh&text=RDF%2FBorsh+for+Ruby)
[![Share on Reddit](https://img.shields.io/badge/share%20on-reddit-red?logo=reddit)](https://reddit.com/submit?url=https://github.com/ruby-rdf/rdf-borsh&title=RDF%2FBorsh+for+Ruby)
[![Share on Hacker News](https://img.shields.io/badge/share%20on-hacker%20news-orange?logo=ycombinator)](https://news.ycombinator.com/submitlink?u=https://github.com/ruby-rdf/rdf-borsh&t=RDF%2FBorsh+for+Ruby)
[![Share on Facebook](https://img.shields.io/badge/share%20on-facebook-1976D2?logo=facebook)](https://www.facebook.com/sharer/sharer.php?u=https://github.com/ruby-rdf/rdf-borsh)
