module UMPTG::Review
  class PackageProcessor < ElementEntryProcessor

    PACKAGE_ELEMENTS = [ 'dc:title', 'dc:creator', 'dc:language', 'dc:rights', 'dc:publisher', 'dc:identifier' ]

    def initialize(args = {})
      xpath = "//*[local-name()='metadata']/*[" + \
              PACKAGE_ELEMENTS.collect {|x| "name()='#{x}'"}.join(' or ') + \
              "]"
      args[:selection_xpath] = xpath
      args[:selection_elements] = PACKAGE_ELEMENTS
      super(args)
    end
  end
end
