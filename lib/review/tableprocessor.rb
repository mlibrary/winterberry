module UMPTG::Review
  class TableProcessor < EntryProcessor
    @@children = [ 'caption', 'colgroup', 'thead', 'tbody', 'tfoot' ]

    def initialize(args = {})
      args[:containers] = [ 'table' ]
      super(args)
    end

    #
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :fragment   XML fragment for Marker to process.
    def new_action(args = {})
      action = UMPTG::Review::TableAction.new(
          name: args[:name],
          fragment: args[:fragment],
          children: @@children
          )
      return action
    end
  end
end
