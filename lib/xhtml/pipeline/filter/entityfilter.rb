module UMPTG::XHTML::Pipeline::Filter
  require 'htmlentities'

  class EntityFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*
    SXPATH

    def initialize(options: nil)
      super(
              name: :xhtml_entity,
              xpath: XPATH,
              options: options
            )

      @decoder = nil
    end

    def review(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      name = issue.name
      reference_node = issue.content

      entity_list = reference_node.children.select {|n| n.type == 5 or n.type == 6 }
      @decoder = HTMLEntities.new if @decoder.nil? and entity_list.count > 0

      entity_list.each do |n|
        content = (@decoder.decode(n) || "")

        if content.empty?
          issue.actions << UMPTG::XML::Pipeline::Action.new(
                  name: name,
                  reference_node: n,
                  warning_message: \
                    "#{name}, found entity #{n}, unable to map to character"
              )
        else
          issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  name: name,
                  reference_node: n,
                  action: :replace_node,
                  markup: content,
                  warning_message: \
                    "#{name}, found entity #{n}"
              )
        end
      end
    end
  end
end
