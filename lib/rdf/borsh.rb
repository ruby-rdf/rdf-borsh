# This is free and unencumbered software released into the public domain.

require 'rdf'

module RDF
  ##
  # RDF/Borsh extension for RDF.rb.
  module Borsh
    autoload :Format, 'rdf/borsh/format'
    autoload :Reader, 'rdf/borsh/reader'
    autoload :Writer, 'rdf/borsh/writer'
  end
end

require_relative 'borsh/version'
