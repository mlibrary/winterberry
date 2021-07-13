module UMPTG::Remediation

  class RemoveTextAlignAction < UMPTG::Action
    def process()
      reference_node = @properties[:reference_node]
      if reference_node.key?("text-align")
        reference_node.remove_attribute("text-align")
      end
      @status = @@COMPLETED
    end
  end
end
