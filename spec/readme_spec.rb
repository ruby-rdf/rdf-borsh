require 'rdf/borsh'

include RDF

RSpec.describe RDF::Borsh do
  describe 'README examples' do
    it 'roundtrip correctly' do
      statement = [RDF::URI("https://rubygems.org/gems/rdf-borsh"), RDFS.label, "RDF/Borsh for Ruby"]

      ### Serializing an RDF graph into an RDF/Borsh file
      RDF::Borsh::Writer.open("mygraph.rdfb") do |writer|
        writer << statement
      end

      ### Parsing an RDF graph from an RDF/Borsh file
      graph = RDF::Graph.load("mygraph.rdfb")
      expect(graph.to_a).to eq([statement])
    end
  end
end
