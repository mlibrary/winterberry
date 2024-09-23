module UMPTG::EPUB::OEBPS::Metadata

  class MetadataTerms < Terms

    def initialize(args = {})
      a = args.clone
      a[:xpath_children] ="./*[local-name()='meta' and not(contains(@property,':'))]"
      super(a)

      @ns_prefix = nil
    end
  end
end
