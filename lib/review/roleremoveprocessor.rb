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
    (local-name()='section' and @role)
    or (local-name()='li' and (@role='doc-endnotes' or @role='doc-endnote'))
    or (local-name()='a' and @role='doc-noteref')
    ]
    HRXPATH

    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: HEADROLE_XPATH
            )
      super(args)
    end

    def action_list(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      action_list = super(args)
      return action_list
    end

    def new_action(args = {})
      a = args.clone
      a[:attribute_name] = "role"
      return [
          RemoveAttributeAction.new(a)
          ]
    end

    private

  end
end
