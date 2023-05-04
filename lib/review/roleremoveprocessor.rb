module UMPTG::Review
  class RoleRemoveProcessor < EntryProcessor
    HEADROLE_XPATH = <<-HRXPATH
    //*[
    local-name()='head'
    ]/*[
    local-name()='meta'
    and @role
    ] |
    //*[
    (local-name()='li' and (@role='doc-endnotes' or @role='doc-endnote'))
    ]
    HRXPATH

    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: HEADROLE_XPATH
            )
      super(args)
    end

    def new_action(args = {})
      a = args.clone
      a[:attribute_name] = "role"
      return [
          RemoveAttributeAction.new(a)
          ]
    end
  end
end
