module UMPTG::EPUB::Archive::OEBPS::Metadata::Schema

  class Terms < UMPTG::EPUB::Archive::OEBPS::Metadata::Terms

    def initialize(args = {})
      super(args)

      @ns_prefix = "schema"
      @xpath_children = "./*[local-name()='meta' and starts-with(@property,concat('#{@ns_prefix}',':'))]"
    end

    def accessMode(args = {})
      return find(meta_property: "accessMode")
    end
  end
end
