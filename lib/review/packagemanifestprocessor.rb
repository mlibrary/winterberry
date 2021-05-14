module UMPTG::Review
  class PackageManifestProcessor < EntryProcessor
    def initialize(args = {})
      args[:containers] = [ 'manifest' ]
      super(args)
    end

    #
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :fragment   XML fragment for Marker to process.
    def new_action(args = {})
      action = UMPTG::Review::PackageManifestAction.new(
          name: args[:name],
          fragment: args[:fragment]
          )
      return action
    end
  end
end

