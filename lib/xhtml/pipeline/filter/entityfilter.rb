module UMPTG::XHTML::Pipeline::Filter
  require 'htmlentities'

  class EntityFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*
    SXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :xhtml_entity
      a[:xpath] = XPATH
      super(a)

      @decoder = nil
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]

      action_list = []

      entity_list = reference_node.children.select {|n| n.type == 5 or n.type == 6 }
      @decoder = HTMLEntities.new if @decoder.nil? and entity_list.count > 0

      entity_list.each do |n|
        content = (@decoder.decode(n) || "")

        if content.empty?
          action_list << UMPTG::XML::Pipeline::Action.new(
                  name: name,
                  reference_node: n,
                  warning_message: \
                    "#{name}, found entity #{n}, unable to map to character"
              )
        else
          action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  name: name,
                  reference_node: n,
                  action: :replace_node,
                  markup: content,
                  warning_message: \
                    "#{name}, found entity #{n}"
              )
        end
      end
      return action_list
    end
  end
end
