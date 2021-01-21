module UMPTG::Keywords

  class KeywordProcessor
    def initialize(args = {})
      @reference_processor = args[:reference_processor]
    end

    def process(doc)
      reference_action_list = @reference_processor.keyword_actions(
                                  :xml_doc => doc
                                )
      reference_action_list.each do |reference_action|
        reference_action.process
        puts reference_action
        puts reference_action.message \
            unless reference_action.message.nil? or reference_action.message.empty?
      end

      return reference_action_list
    end
  end
end
