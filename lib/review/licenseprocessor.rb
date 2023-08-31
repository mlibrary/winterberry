module UMPTG::Review
  class LicenseProcessor < EntryProcessor
    attr_accessor :license_file, :license_fragment

    XPATH = <<-XP
    //*[
    local-name()='body'
    ]//*[
    @role='doc-credit'
    or @epub:type='copyright-page'
    or @class="copyrightt"
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
      a[:license_fragment] = @license_fragment
      a[:epub] = @epub

      return [
          InsertLicenseAction.new(a)
          ]
    end
  end
end
