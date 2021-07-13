module UMPTG::Remediation

  class RemoveMarginBottomAction < UMPTG::Action
    def process()
      reference_node = @properties[:reference_node]
      if reference_node.key?("margin-bottom")
        reference_node.remove_attribute("margin-bottom")
      end
      @status = @@COMPLETED
    end
  end
end
