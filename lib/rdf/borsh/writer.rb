# This is free and unencumbered software released into the public domain.

require 'extlz4'
require 'rdf'
require 'sorted_set'
require 'stringio'

module RDF::Borsh
  class Writer < RDF::Writer
    format RDF::Borsh::Format

    MAGIC = RDF::Borsh::Format::MAGIC
    VERSION = RDF::Borsh::Format::VERSION
    FLAGS = RDF::Borsh::Format::FLAGS
    LZ4HC_CLEVEL_MAX = 12

    def initialize(output = $stdout, **options, &block)
      @terms_dict, @terms_map = [], {}
      @quads_set = SortedSet.new

      super(output, **options) do
        if block_given?
          case block.arity
            when 0 then self.instance_eval(&block)
            else block.call(self)
          end
        end
      end
    end

    def write_triple(subject, predicate, object)
      self.write_quad(subject, predicate, object, nil)
    end

    def write_quad(subject, predicate, object, context)
      s = self.intern_term(subject)
      p = self.intern_term(predicate)
      o = self.intern_term(object)
      g = self.intern_term(context)
      @quads_set << [g, s, p, o]
    end

    def flush
      self.finish
      super
    end

    def finish
      self.write_header
      self.write_terms
      self.write_quads
    end

    # Writes the uncompressed header.
    def write_header
      @output.binmode
      @output.write([MAGIC, VERSION, FLAGS].pack('a4CC'))
      @output.write([@quads_set.size].pack('V'))
    end

    # Writes the compressed terms dictionary.
    def write_terms
      buffer = StringIO.open do |output|
        output.binmode
        output.write([@terms_dict.size].pack('V'))
        @terms_dict.each do |term|
          output.write(case
            when term.iri?
              string = term.to_s
              [1, string.bytesize, string].pack('CVa*')
            when term.node?
              string = term.id.to_s
              [2, string.bytesize, string].pack('CVa*')
            when term.literal? && term.plain?
              string = term.value.to_s
              [3, string.bytesize, string].pack('CVa*')
            when term.literal? && term.datatype?
              string = term.value.to_s
              datatype = term.datatype.to_s
              [4, string.bytesize, string, datatype.bytesize, datatype].pack('CVa*Va*')
            when term.literal? && term.language?
              string = term.value.to_s
              language = term.language.to_s
              [5, string.bytesize, string, datatype.language, language].pack('CVa*Va*')
            else
              raise RDF::WriterError, "unsupported RDF/Borsh term type: #{term.inspect}"
          end)
        end
        self.compress(output.string)
      end
      @output.write([buffer.size].pack('V'))
      @output.write(buffer)
    end

    def write_quads
      buffer = StringIO.open do |output|
        output.binmode
        output.write([@quads_set.size].pack('V'))
        @quads_set.each do |quad|
          output.write(quad.pack('v4'))
        end
        self.compress(output.string)
      end
      @output.write([buffer.size].pack('V'))
      @output.write(buffer)
    end

    # @return [Integer]
    def intern_term(term)
      return 0 if term.nil? # for the default graph
      term_id = @terms_map[term]
      if !term_id
        term_id = @terms_dict.size + 1
        @terms_dict << term
        @terms_map[term] = term_id
      end
      term_id
    end

    def compress(data)
      LZ4::BlockEncoder.new(LZ4HC_CLEVEL_MAX).encode(data)
    end
  end # Writer
end # RDF::Borsh
