module UMPTG::Review

  #
  class PackageAction < Action
    def process(args = {})
      super(args)

      pck_version = @fragment.node["version"]
      case
      when pck_version.nil?
        add_warning_msg("Package: EPUB version not specified.")
      when pck_version[0] == '3'
        add_info_msg("Package:   EPUB version is #{pck_version}")
      else
        add_warning_msg("Package: EPUB version is #{pck_version}.")
      end

      @has_elements.each do |elem_name, exists|
          add_info_msg("Package:   contains <#{elem_name}>.") if exists
          add_info_msg("Package:   contains no <#{elem_name}>.") unless exists
      end

      @status = Action.COMPLETED
    end
  end
end
