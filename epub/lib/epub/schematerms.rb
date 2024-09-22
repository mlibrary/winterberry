module UMPTG::EPUB

  class SchemaTerms < Node

    def initialize(args = {})
      super(args)

      @ns_prefix = "schema"
      @xpath_children = "./*[local-name()='meta' and starts-with(@property,concat('#{@ns_prefix}',':'))]"
    end

    def accessMode(args = {})
      return find(meta_property: "accessMode")
    end

    def add(args = {})
      raise "not implemented"
    end
  end
end
