module UMPTG::Review

  class InsertLicenseAction < NormalizeAction
    def process(args = {})
      super(args)

      entry_name = @properties[:name]
      reference_node = @properties[:reference_node]
      epub = @properties[:epub]
      license_file = @properties[:license_file]
      license_fragment = @properties[:license_fragment]

      unless license_fragment.nil?
        @status = Action.COMPLETED

        # Insert license markup just before the first para.
        firstpara_node = reference_node.document.xpath("//*[local-name()='body']//*[local-name()='p']").first
        if firstpara_node.nil?
          add_error_msg("unable to find license first para.")
          return
        end

        license_fragment.xpath("./*").each {|n| firstpara_node.add_previous_sibling(n) }
        add_info_msg("added license info")

        @status = NormalizeAction.NORMALIZED
        return
      end

      # Locate the license file in the EPUB archive and
      # construct the relative to the file.
      bname = File.basename(license_file)
      lic_entry = epub.entries.select {|e| File.basename(e.name) == bname }
      lic_dir = Pathname.new(File.dirname(lic_entry.first.name)).relative_path_from(File.dirname(entry_name))
      lic_path = File.join(lic_dir, File.basename(lic_entry.first.name))

      # Add the license markup to the copyright section. Attempt to insert
      # it before the first para, otherwise append as the last child.
      license_node = reference_node.document.parse("<p><img src=\"#{lic_path}\"/></p>")
      p_node = reference_node.xpath("//*[local-name()='p']").first
      if p_node.nil?
        reference_node.add_child(license_node)
        add_info_msg("appended license \"#{File.basename(license_file)}\".")
      else
        p_node.add_previous_sibling(license_node)
        add_info_msg("inserted license \"#{File.basename(license_file)}\".")
      end

      @status = NormalizeAction.NORMALIZED
    end
  end
end

