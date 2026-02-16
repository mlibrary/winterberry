module UMPTG::EPUB::Archive::OEBPS::Metadata

  class Rendition < Node

    def initialize(args = {})
      a = args.clone
      a[:xpath_node] = "//*[local-name()='metadata']"
      super(a)

      @ns_prefix = "rendition"
      @xpath_children = "./*[local-name()='meta' and starts-with(@property,'#{@ns_prefix}:')]"
    end

    def add(args = {})
      raise "not implemented"
    end
  end
end
