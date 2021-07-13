module UMPTG::Remediation

  class FixIdAction < UMPTG::Action
    def process()
      reference_node = @properties[:reference_node]
      id = reference_node['id']
      name = @properties[:name]
      newName = File.basename(name, ".*")

      reference_node['id'] = "#{newName}_#{id}"
      @status = @@COMPLETED
    end
  end
end
