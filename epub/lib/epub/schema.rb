module UMPTG::EPUB

  class Schema < Node
    attr_reader :terms

    def initialize(args = {})
      super(args)

      @terms = SchemaTerms.new(args)
    end

    def find(args = {})
      return children if args.empty?

      return @terms.find(args)
    end

    def add(args = {})
      raise "not implemented"
    end
  end
end
