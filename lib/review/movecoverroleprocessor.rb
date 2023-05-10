module UMPTG::Review
  class MoveCoverRoleProcessor < EntryProcessor
    COVERROLE_XPATH = <<-HRXPATH
    //*[
    (local-name()='section' and @role='doc-cover')
    ]
    HRXPATH

    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: COVERROLE_XPATH
            )
      super(args)
    end

    def new_action(args = {})
      a1 = args.clone
      a1[:attribute_name] = "role"
      a2 = args.clone
      new_action_list = [
          RemoveAttributeAction.new(a1)
          ]
      img_node = a1[:reference_node].xpath("//*[local-name()='img']").first
      unless img_node.nil?
        a2[:reference_node] = img_node
        a2[:attribute_name] = 'role'
        a2[:attribute_value] = a1[:reference_node]['role']
        new_action_list << SetAttributeValueAction.new(a2)
      end
      return new_action_list
    end

    private

  end
end
