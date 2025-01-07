# This is free and unencumbered software released into the public domain.

module RDF
  ##
  # RDF/Borsh.
  module Borsh
    autoload :Format, 'rdf/borsh/format'
    autoload :Reader, 'rdf/borsh/reader'
    autoload :Writer, 'rdf/borsh/writer'
  end
end

require 'rdf/borsh/version'
