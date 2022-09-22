module UMPTG::Review
  class ListProcessor < EntryProcessor
    @@children = [ 'p' ]

    def initialize(args = {})
      args[:containers] = [ 'li' , 'dt', 'dd' ]
      super(args)
    end

    #
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :fragment   XML fragment for Marker to process.
    def new_action(args = {})
      action = UMPTG::Review::ListAction.new(
          name: args[:name],
          fragment: args[:fragment],
          children: @@children
          )
      return action
    end
  end
end
