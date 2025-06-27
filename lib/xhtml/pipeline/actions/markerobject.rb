module UMPTG::XHTML::Pipeline::Actions

  # Class represents additional resources (Marker)
  # found when processing an EPUB. The super contains
  # the Marker node while this class extends
  # the base to include the resource name.
  class MarkerObject < UMPTG::Object
    attr_accessor :resource_name, :caption_text
    attr_reader :node, :name, :alt_text, :caption

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

      if @properties.key?(:caption_text)
        @caption_text = @properties[:caption_text]
      else
        @caption_text = @caption.nil? ? "" : \
              @caption.text.strip.gsub(/[\n]+/, ' ')
      end

      @alt_text = @node.has_attribute?("alt") ? @node["alt"] : ""
    end
  end
end
