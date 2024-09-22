module UMPTG::EPUB

  class Schema < Node

    def initialize(args = {})
      super(args)
    end

    def find(args = {})
      return children if args.empty?

      a = args.clone
      a[:namespace_attribute_prefix] = "schema"

      return @rendition.metadata.find(a)
    end

    def add(args = {})
      raise "not implemented"
    end
  end
end
