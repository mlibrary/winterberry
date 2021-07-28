module UMPTG::Review
  class PackageProcessor < ElementEntryProcessor
    def initialize(args = {})
      args[:container_elements] = [ 'metadata' ]
      args[:child_elements] = [ 'dc:title', 'dc:creator', 'dc:language', 'dc:rights', 'dc:publisher', 'dc:identifier' ]
      super(args)
    end
  end
end
