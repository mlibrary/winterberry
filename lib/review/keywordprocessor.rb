module UMPTG::Review
  class KeywordProcessor < EntryProcessor
    KEYWORD_XPATH = <<-KXPATH
    //*[
    local-name()='span' and (@class='tetr' or @class='tetr-i')
    ]
    KXPATH

    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: KEYWORD_XPATH
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
      return [
          LinkKeywordAction.new(args)
          ]
    end
  end
end
