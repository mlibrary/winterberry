module UMPTG::XML::Pipeline::Actions

  class AddNamespaceAction < NormalizeAction
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      prefix = @properties[:namespace_prefix]
      prefix = prefix.nil? ? "" : prefix
      uri = @properties[:namespace_uri]
      uri = uri.nil? ? "" : uri

      if prefix.empty?
        add_error_msg("missing namespace prefix")
        @status = UMPTG::Action.FAILED
        return
      end

      if uri.empty?
        add_error_msg("missing namespace URI")
        @status = UMPTG::Action.FAILED
        return
      end

      reference_node.add_namespace(prefix, uri)
      add_info_msg("added #{reference_node.name}/@#{prefix}=\"#{uri}\"")
      @status = UMPTG::Action.COMPLETED
    end
  end
end

