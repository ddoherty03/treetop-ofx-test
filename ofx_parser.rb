# frozen_string_literal: true

require 'treetop'

module Ofx
  class Parser
    attr_reader :scanner, :parser

    def initialize(version)
      case version
      when 100..199
        Treetop.load(File.join(__dir__, 'ofx_v1.treetop'))
      when 200..299
        Treetop.load(File.join(__dir__, 'ofx_v2.treetop'))
      else
        raise ImplementationError, "OFX version `#{version}` not implemented"
      end
      @parser = OfxGrammarParser.new
    end

    def parse(str)
      tree = parser.parse(str)
      # If the AST is nil then there was an error during parsing
      # we need to report a simple error message to help the user
      if tree.nil?
        msg = "failure: #{@parser.failure_reason.sub(/after /, "after:\n")}"
        puts msg
        exit 1
      end
      clean_tree(tree)
      tree
    end

    # Eliminate nodes that don't correspond to one of the Node classes
    def clean_tree(root_node)
      return if root_node.nil? || root_node.elements.nil?

      root_node.elements.delete_if do |node|
        node.class.name == 'Treetop::Runtime::SyntaxNode'
      end
      root_node.elements.each do |node|
        clean_tree(node)
      end
    end
  end
end
