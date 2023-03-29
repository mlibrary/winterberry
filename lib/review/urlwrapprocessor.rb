module UMPTG::Review
  class URLWrapProcessor < EntryProcessor
    URL_XPATH = <<-UXPATH
    //*[
    local-name()='a' and starts-with(@href,'http')
    ]
    UXPATH

    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: URL_XPATH
            )
      super(args)
    end

    def action_list(args = {})
      action_list = super(args)
      return action_list
    end

    def new_action(args = {})
      a = args.clone
      a[:attribute_name] = "class"
      a[:attribute_value] = "url"
      a[:attribute_append] = true
      return [
          SetAttributeValueAction.new(a)
          ]
    end

    private

  end
end
