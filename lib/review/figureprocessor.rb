module UMPTG::Review
  class FigureProcessor < EntryProcessor
    #@@containers = [ 'figure', 'img' ]
    @@children = [ 'figcaption' ]
    @@classes = [ 'figcap', 'figh' ]

    def initialize(args = {})
      args[:containers] = [ 'figure' ]
      super(args)
    end

    def action_list(args = {})
      action_list = super(args)

      unless action_list.empty?
        img_processor = ImgProcessor.new
        img_action_list = []
        action_list.each do |action|
          img_action_list = img_processor.action_list(
                  :name => args[:name],
                  :content => action.fragment.node.to_xml
              )
        end
        action_list += img_action_list
      end
      return action_list
    end

    # Instantiate a new Action for the XML fragment for a figure.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :fragment   XML fragment for Marker to process.
    def new_action(args = {})
      fragment = args[:fragment]

      case fragment.node.name
      when 'img'
        action = UMPTG::Review::ImgAction.new(
            name: args[:name],
            fragment: args[:fragment]
            )
      when 'figure'
        action = UMPTG::Review::FigureAction.new(
            name: args[:name],
            fragment: args[:fragment],
            children: @@children,
            classes: @@classes
            )
      else
        action = UMPTG::Review::Action.new(
            name: args[:name],
            fragment: args[:fragment]
            )
      end
      return action
    end
  end
end

