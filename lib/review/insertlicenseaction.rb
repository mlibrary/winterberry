module UMPTG::Review

  class InsertLicenseAction < NormalizeAction
    def process(args = {})
      super(args)

      entry_name = @properties[:name]
      reference_node = @properties[:reference_node]
      epub = @properties[:epub]
      license_fragment = @properties[:license_fragment]
      @status = Action.COMPLETED
      return if license_fragment.nil?

      # Insert license markup just before the first para.
      firstpara_node = reference_node.document.xpath("//*[local-name()='body']//*[local-name()='p']").first
      if firstpara_node.nil?
        add_error_msg("unable to find license first para.")
          @status = Action.FAILED
        return
      end

      license_fragment.xpath("./*").each {|n| firstpara_node.add_previous_sibling(n) }
      add_info_msg("added license info")

      @status = NormalizeAction.NORMALIZED
    end
  end
end

