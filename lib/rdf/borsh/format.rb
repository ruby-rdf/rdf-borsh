# This is free and unencumbered software released into the public domain.

require 'rdf/format'

module RDF::Borsh
  class Format < RDF::Format
    content_type 'application/x-rdf+borsh', extension: :borsh
    reader { RDF::Borsh::Reader }
    writer { RDF::Borsh::Writer }

    MAGIC = 'RDFB'.freeze
    VERSION = '1'.ord
    FLAGS = 0b00000111

    def self.name; "RDF/Borsh"; end

    def self.detect(sample)
      sample[0..4] == [MAGIC, VERSION].pack('a4C')
    end
  end # Format
end # RDF::Borsh
