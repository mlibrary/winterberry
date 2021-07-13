module UMPTG::Remediation

  class FixImageWidthAction < UMPTG::Action
    def process()
      reference_node = @properties[:reference_node]
      name = @properties[:name]

      width = reference_node['width']
      mdata = width.match(/^([0-9]?)/)
      unless mdata.nil?
        reference_node['width'] = mdata[1]
      end
      @status = @@COMPLETED
    end
  end
end
