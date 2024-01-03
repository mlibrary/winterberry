module UMPTG::XML::Pipeline::Action

  class EmbedAction < NormalizeAction

    # Method generates the XML markup for a container that
    # wraps the default display of a specific resource
    # (generally just an image).
    def self.default_container(reference_node, container = 'div')
      return reference_node.document.create_element(container, :class => "default-media-display")
    end

    # Method generates the XML markup for a container that
    # wraps the Fulcrum enhanced display of a specific resource
    # (interactive image, audio, video, etc.).
    def self.embed_container(reference_node, container = 'div')
      return reference_node.document.create_element(container, :class => "enhanced-media-display")
    end
  end
end
