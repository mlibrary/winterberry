module UMPTG::Review
  class TableProcessor < ElementEntryProcessor

    TABLE_ELEMENTS = [ 'caption', 'colgroup', 'thead', 'tbody', 'tfoot' ]

    def initialize(args = {})
      xpath = "//*[local-name()='table']//*[" + \
              TABLE_ELEMENTS.collect {|x| "name()='#{x}'"}.join(' or ') + \
              "]"
      args[:selection_xpath] = xpath
      args[:selection_elements] = TABLE_ELEMENTS
      super(args)
    end
  end
end
