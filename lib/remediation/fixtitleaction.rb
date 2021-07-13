module UMPTG::Remediation

  class FixTitleAction < UMPTG::Action
    def process()
      reference_node = @properties[:reference_node]
      name = @properties[:name]
      reference_node.content = name
      @status = @@COMPLETED
    end
  end
end
