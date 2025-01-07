# This is free and unencumbered software released into the public domain.

require 'extlz4'
require 'rdf'
require 'stringio'

module RDF::Borsh
  class Reader < RDF::Reader
    format RDF::Borsh::Format

    MAGIC = RDF::Borsh::Format::MAGIC
    VERSION = RDF::Borsh::Format::VERSION
    FLAGS = RDF::Borsh::Format::FLAGS

    def initialize(input = $stdin, **options, &block)
      super(input, **options) do
        input = @input
        @version, @flags, @quad_count = self.read_header

        input_size = input.read(4).unpack('V').first
        @input = StringIO.new(self.decompress(input.read(input_size)), 'rb')
        @terms = [nil] + self.read_terms

        input_size = input.read(4).unpack('V').first
        @input = StringIO.new(self.decompress(input.read(input_size)), 'rb')
        _ = @input.read(4).unpack('V').first

        if block_given?
          case block.arity
            when 0 then self.instance_eval(&block)
            else block.call(self)
          end
        end
      end
    end

    def read_statement
      quad_data = @input.read(8) or raise EOFError
      g, s, p, o = quad_data.unpack('v4').map! { |term_id| @terms[term_id] }
      RDF::Statement.new(s, p, o, graph_name: g)
    end

    def read_quad; self.read_statement.to_quad; end
    def read_triple; self.read_statement.to_triple; end

    ##
    # Reads the compressed terms dictionary.
    def read_terms
      term_count = @input.read(4).unpack('V').first
      term_count.times.map do
        term_kind, term_string_size = @input.read(5).unpack('CV')
        term_string = @input.read(term_string_size)

        case term_kind
          when 1 then RDF::URI(term_string)
          when 2 then RDF::Node(term_string)
          when 3 then RDF::Literal(term_string)
          when 4
            term_datatype_size = @input.read(4).unpack('V')
            RDF::Literal(term_string, datatype: @input.read(term_datatype_size))
          when 5
            term_language_size = @input.read(4).unpack('V')
            RDF::Literal(term_string, language: @input.read(term_language_size))
          else
            raise RDF::ReaderError, "unknown RDF/Borsh term type: #{term_kind}"
        end
      end
    end

    ##
    # Reads the uncompressed header.
    def read_header
      magic = @input.read(4).unpack('a4').first
      raise RDF::ReaderError, "invalid RDF/Borsh header: #{magic.inspect}" if magic != MAGIC

      version = @input.read(1).unpack('C').first
      raise RDF::ReaderError, "invalid RDF/Borsh version: #{version}" if version != VERSION

      flags = @input.read(1).unpack('C').first
      raise RDF::ReaderError, "invalid RDF/Borsh flags: #{flags}" if flags != FLAGS

      quad_count = @input.read(4).unpack('V').first
      [version, flags, quad_count]
    end

    def decompress(data)
      LZ4::BlockDecoder.new.decode(data)
    end
  end # Reader
end # RDF::Borsh
