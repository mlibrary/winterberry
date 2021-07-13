module UMPTG::Remediation

  class RemoveMarginTopAction < UMPTG::Action
    def process()
      reference_node = @properties[:reference_node]
      if reference_node.key?("margin-top")
        reference_node.remove_attribute("margin-top")
      end
      @status = @@COMPLETED
    end
  end
end
