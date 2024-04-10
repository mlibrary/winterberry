module UMPTG::Fulcrum::Metadata

  # Class represents additional resources (Marker)
  # found when processing an EPUB. The super contains
  # the Marker node while this class extends
  # the base to include the resource name.
  class MarkerObject < UMPTG::Object
    attr_accessor :resource_name
    attr_reader :node, :name, :caption, :caption_text

    # Arguments:
    #   :node           XML node
    #   :name           Identifier, e.g. EPUB entry name.
    #   :resource_name  Resource name associated with fragment.
    #   :caption        Resource caption.
    def initialize(args = {})
      super(args)

      @node = @properties[:node]
      @name = @properties[:name]
      @resource_name = @properties[:resource_name]
      @caption = @properties[:caption]
      @caption_text = @properties[:caption_text]
    end
  end
end
