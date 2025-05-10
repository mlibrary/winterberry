module UMPTG::EPUB::Archive::OEBPS::Metadata::DC

  class Terms < UMPTG::EPUB::Archive::OEBPS::Metadata::Terms
    attr_reader :ns_prefix

    NAMESPACE_URI = "http://purl.org/dc/terms/"

    def initialize(args = {})
      super(args)

      @ns_prefix = UMPTG::EPUB::Archive::OEBPS::Metadata::Metadata.namespace_prefix(obj_node, NAMESPACE_URI)
      @xpath_children = "./*[local-name()='meta' and starts-with(@property,concat('#{@ns_prefix}',':'))]"
    end

    def modified(args = {})
      modified_date = args[:meta_property_value]

      a = args.clone
      a[:meta_property] = "modified"
      mdate_nodelist = find(a)

      return mdate_nodelist if modified_date.nil?

      if mdate_nodelist.empty?
        mdate_nodelist = add(a)
      else
        mdate_nodelist.first.content = modified_date
      end
      return mdate_nodelist
    end

    def self.NAMESPACE_URI
      return NAMESPACE_URI
    end
  end
end
