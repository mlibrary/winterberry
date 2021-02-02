module UMPTG::Resources

  require 'nokogiri'

  # Class is base class for processing resource reference Actions.
  class Action < UMPTG::Action

    attr_reader :reference_action_def, :reference_container,
            :reference_node, :name

    # Parameters:
    #   :name                   XML content identifer
    #   :reference_node         XML node for resource reference
    #   :reference_container    Parent XML node for resource reference
    #   :reference_action_def   Processing definition for this Action,
    #                             either embed|link, or insert
    def initialize(args = {})
      super(args)

      @name = @properties[:name]
      @reference_node = @properties[:reference_node]
      @reference_container = @properties[:reference_container]
      @reference_action_def = @properties[:reference_action_def]
    end

    # Base method that should be overridden
    def process
      raise "#{self.class}: method #{__method__} must be implemented for #{@reference_action_def.to_s}."
    end

    # Method generates XML markup to link a resource.
    #
    # Parameter:
    #   descr           Text to include within the link
    def link_markup(descr = nil)
      descr = "View resource." if descr == nil

      link = @reference_action_def.link
      return "<a href=\"#{link}\" target=\"_blank\">#{descr}</a>"
    end

    # Method generates the XML markup for embedding
    # a specific resource.
    def embed_fragment
      emb_markup = reference_action_def.embed_markup
      if emb_markup == nil or emb_markup.strip.empty?
        @message = "Warning: no embed markup for resource node #{reference_action_def.reference_name}"
        return nil
      end

      emb_fragment = Nokogiri::XML.fragment(emb_markup)
      if emb_fragment.nil?
        @message = "Warning: error creating embed markup document for resource node #{reference_action_def.reference_name}"
      end
      return emb_fragment
    end

    # Method generates the XML markup for a container that
    # wraps the default display of a specific resource
    # (generally just an image).
    def default_container(container = 'div')
      return @reference_node.document.create_element(container, :class => "default-media-display")
    end

    # Method generates the XML markup for a container that
    # wraps the Fulcrum enhanced display of a specific resource
    # (interactive image, audio, video, etc.).
    def embed_container(container = 'div')
      container = @reference_node.document.create_element(container, :class => "enhanced-media-display")
      container
    end

    # Generate a string for this Action.
    def to_s
      return super.to_s + ", #{@reference_action_def.to_s}"
    end

    # For the specified XML element, attempt to locate a caption
    # element within.
    def self.find_caption(container)
      caption = container.xpath(".//*[local-name()='figcaption' or @class='figcap' or @class='figh']")
      return caption
    end
  end
end
