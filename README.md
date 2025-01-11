# RDF/Borsh for Ruby

[![License](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://unlicense.org)
[![Compatibility](https://img.shields.io/badge/ruby-3.0%2B-blue)](https://rubygems.org/gems/rdf-borsh)
[![Package](https://img.shields.io/gem/v/rdf-borsh)](https://rubygems.org/gems/rdf-borsh)
[![Documentation](https://img.shields.io/badge/rubydoc-latest-blue)](https://rubydoc.info/gems/rdf-borsh)

**RDF/Borsh** is a [Ruby] library and [RDF.rb] extension for encoding
and decoding [RDF] knowledge graphs in the [Borsh] binary serialization
format.

## ✨ Features

- 100% pure Ruby with minimal dependencies and no bloat.
- Plays nice with others: entirely contained in the `RDF::Borsh` module.
- 100% free and unencumbered public domain software.

## 🛠️ Prerequisites

- [Ruby] 3.0+

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

## 📚 Reference

https://rubydoc.info/gems/rdf-borsh

## 👨‍💻 Development

```bash
git clone https://github.com/ruby-rdf/rdf-borsh.git
```

- - -

[![Share on Twitter](https://img.shields.io/badge/share%20on-twitter-03A9F4?logo=twitter)](https://twitter.com/share?url=https://github.com/ruby-rdf/rdf-borsh&text=RDF%2FBorsh+for+Ruby)
[![Share on Reddit](https://img.shields.io/badge/share%20on-reddit-red?logo=reddit)](https://reddit.com/submit?url=https://github.com/ruby-rdf/rdf-borsh&title=RDF%2FBorsh+for+Ruby)
[![Share on Hacker News](https://img.shields.io/badge/share%20on-hacker%20news-orange?logo=ycombinator)](https://news.ycombinator.com/submitlink?u=https://github.com/ruby-rdf/rdf-borsh&t=RDF%2FBorsh+for+Ruby)
[![Share on Facebook](https://img.shields.io/badge/share%20on-facebook-1976D2?logo=facebook)](https://www.facebook.com/sharer/sharer.php?u=https://github.com/ruby-rdf/rdf-borsh)

[Borsh]: https://borsh.io
[RDF]: https://www.w3.org/TR/rdf12-concepts/
[RDF.rb]: https://github.com/ruby-rdf/rdf
[Ruby]: https://ruby-lang.org
