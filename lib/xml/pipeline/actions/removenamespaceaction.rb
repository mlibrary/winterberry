module UMPTG::XML::Pipeline::Actions

  class RemoveNamespaceAction < NormalizeAction
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      remove_all = @properties[:namespace_remove_all]

      if remove_all
        reference_node.document.remove_namespaces!
        add_info_msg("removed all namespaces")
        @status = UMPTG::Action.COMPLETED
      else
        add_error_msg("remove specific namespace not implemented.")
        @status = UMPTG::Action.FAILED
      end
    end
  end
end

