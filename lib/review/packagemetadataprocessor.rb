module UMPTG::Review
  class PackageMetadataProcessor < EntryProcessor
    @@children = [ 'dc:title', 'dc:creator', 'dc:language', 'dc:rights', 'dc:publisher', 'dc:identifier' ]

    def initialize(args = {})
      args[:containers] = [ 'metadata' ]
      super(args)
    end

    #
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :fragment   XML fragment for Marker to process.
    def new_action(args = {})
      action = UMPTG::Review::PackageMetadataAction.new(
          name: args[:name],
          fragment: args[:fragment],
          children: @@children
          )
      return action
    end
  end
end

