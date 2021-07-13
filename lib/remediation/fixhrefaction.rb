module UMPTG::Remediation

  class FixHrefAction < UMPTG::Action
    def process()
      reference_node = @properties[:reference_node]
      href = reference_node['href']

      reference_node['href'] = "#" + href
      @status = @@COMPLETED
    end
  end
end
