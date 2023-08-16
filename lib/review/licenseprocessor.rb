module UMPTG::Review
  class LicenseProcessor < EntryProcessor
    attr_accessor :license_file

    XPATH = <<-XP
    //*[
    local-name()='body'
    ]//*[
    @role='doc-credit'
    ]
    XP

    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: XPATH
            )
      super(args)
    end

    def new_action(args = {})
      a = args.clone
      a[:license_file] = @license_file
      a[:epub] = @epub

      return [
          InsertLicenseAction.new(a)
          ]
    end
  end
end
