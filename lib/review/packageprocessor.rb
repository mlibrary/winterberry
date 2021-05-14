module UMPTG::Review
  class PackageProcessor < EntryProcessor
    @@children = [ 'metadata' ]

    def initialize(args = {})
      args[:containers] = [ 'package' ]
      super(args)
    end

    def action_list(args = {})
      action_list = super(args)

      metadata_processor = PackageMetadataProcessor.new
      manifest_processor = PackageManifestProcessor.new
      metadata_action_list = []
      manifest_action_list = []
      action_list.each do |action|
        metadata_action_list = metadata_processor.action_list(
                  :name => args[:name],
                  :content => action.fragment.node.to_xml
              )

        manifest_action_list = manifest_processor.action_list(
                  :name => args[:name],
                  :content => action.fragment.node.to_xml
              )
      end
      return action_list + metadata_action_list + manifest_action_list
    end

    #
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :fragment   XML fragment for Marker to process.
    def new_action(args = {})
      action = UMPTG::Review::PackageAction.new(
          name: args[:name],
          fragment: args[:fragment],
          children: @@children
          )
      return action
    end
  end
end
