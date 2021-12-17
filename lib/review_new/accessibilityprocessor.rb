module UMPTG::Review
  class AccessibilityProcessor < EntryProcessor
    ACCESS_XPATH = <<-AXPATH
    //*[local-name()='span' and @epub:type='pagebreak']
    AXPATH

    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: ACCESS_XPATH
            )
      super(args)
    end

    def action_list(args = {})
      reference_action_list = super(args)
      reference_action_list.each do |action|
        action.add_info_msg("found page break #{action.reference_node['aria-label']}")
      end
      return reference_action_list
    end
  end
end
