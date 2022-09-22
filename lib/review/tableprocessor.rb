module UMPTG::Review
  class TableProcessor < ElementEntryProcessor
    def initialize(args = {})
      args[:container_elements] = [ 'table' ]
      args[:child_elements] = [ 'caption', 'colgroup', 'thead', 'tbody', 'tfoot' ]
      super(args)
    end
  end
end
