module UMPTG::XHTML::Pipeline::Filter
  require 'htmlentities'

  class EntityFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_entity,
              XPATH,
              options: options
            )

      @decoder = nil
    end

    def review(issue, options: {})
      super(
              issue,
              options: options
           )

      entity_list = issue.content.children.select {|n| n.type == 5 or n.type == 6 }
      @decoder = HTMLEntities.new if @decoder.nil? and entity_list.count > 0

      entity_list.each do |n|
        content = (@decoder.decode(n) || "")

        if content.empty?
          issue.actions << UMPTG::XML::Pipeline::Action.new(
                  issue,
                  options: {
                      warning_message: \
                        "#{issue.name}, found entity #{n}, unable to map to character"
                    }
              )
        else
          issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  issue,
                  options: {
                      action: :replace_node,
                      markup: content,
                      warning_message: \
                        "#{name}, found entity #{n}"
                    }
              )
        end
      end
    end
  end
end
