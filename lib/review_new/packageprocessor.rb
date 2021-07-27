module UMPTG::Review
  class PackageProcessor < EntryProcessor

    def initialize(args = {})
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
    def new_action(args = {})
      return super(args)
    end
  end
end
