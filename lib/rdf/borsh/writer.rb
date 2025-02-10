# This is free and unencumbered software released into the public domain.

require 'borsh'
require 'extlz4'
require 'rdf'
require 'sorted_set'

module RDF::Borsh
  class Writer < RDF::Writer
    format RDF::Borsh::Format

    MAGIC = RDF::Borsh::Format::MAGIC
    VERSION = RDF::Borsh::Format::VERSION
    FLAGS = RDF::Borsh::Format::FLAGS
    LZ4HC_CLEVEL_MIN = 2
    LZ4HC_CLEVEL_DEFAULT = 9
    LZ4HC_CLEVEL_MAX = 12

    ##
    # Initializes the RDF/Borsh writer.
    #
    # @param  [IO, StringIO] output
    # @param  [Integer, #to_i] compression
    # @param  [Hash{Symbol => Object}] options
    # @yield  [writer]
    # @yieldparam  [RDF::Borsh::Writer] writer
    # @yieldreturn [void]
    # @return [void]
    def initialize(output = $stdout, compression: LZ4HC_CLEVEL_MAX, **options, &block)
      output.extend(Borsh::Writable)
      output.binmode if output.respond_to?(:binmode)

      @terms_dict, @terms_map = [], {}
      @quads_set = SortedSet.new
      @compression = (compression || LZ4HC_CLEVEL_MAX).to_i

      super(output, **options) do
        if block_given?
          case block.arity
            when 0 then self.instance_eval(&block)
            else block.call(self)
          end
          self.finish
        end
      end
    end

    ##
    # Writes an RDF triple.
    #
    # @param  [RDF::Resource] subject
    # @param  [RDF::URI] predicate
    # @param  [RDF::Term] object
    # @return [void]
    def write_triple(subject, predicate, object)
      self.write_quad(subject, predicate, object, nil)
    end

    ##
    # Writes an RDF quad.
    #
    # @param  [RDF::Resource] subject
    # @param  [RDF::URI] predicate
    # @param  [RDF::Term] object
    # @param  [RDF::Resource] context
    # @return [void]
    def write_quad(subject, predicate, object, context)
      s = self.intern_term(subject)
      p = self.intern_term(predicate)
      o = self.intern_term(object)
      g = self.intern_term(context)
      @quads_set << [g, s, p, o]
    end

    ##
    # Flushes the output.
    #
    # @return [void]
    def flush
      self.finish
      super
    end

    ##
    # Finishes writing the output.
    #
    # @return [void]
    def finish
      self.write_header
      self.write_terms
      self.write_quads
    end

    protected

    ##
    # Writes the uncompressed header.
    #
    # @return [void]
    def write_header
      @output.binmode if @output.respond_to?(:binmode)
      @output.write([MAGIC, VERSION, FLAGS].pack('a4CC'))
      @output.write_u32(@quads_set.size)
    end

    ##
    # Writes the compressed terms dictionary.
    #
    # @return [void]
    def write_terms
      buffer = self.compress do |output|
        output.write_u32(@terms_dict.size)
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
      end
      @output.write_u32(buffer.size)
      @output.write(buffer)
    end

    ##
    # Writes the compressed quads set.
    #
    # @return [void]
    def write_quads
      buffer = self.compress do |output|
        output.write_u32(@quads_set.size)
        @quads_set.each do |quad|
          quad.each { |tid| output.write_u16(tid) }
        end
      end
      @output.write_u32(buffer.size)
      @output.write(buffer)
    end

    ##
    # Interns the given RDF term.
    #
    # @param  [RDF::Term] term
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

    ##
    # @yield [Borsh::Buffer]
    # @return [String]
    def compress(&block)
      uncompressed = Borsh::Buffer.open(&block)
      LZ4::BlockEncoder.new(@compression).encode(uncompressed)
    end
  end # Writer
end # RDF::Borsh
