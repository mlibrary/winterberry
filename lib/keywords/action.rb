module UMPTG::Keywords

  require 'nokogiri'

  class Action
    @@PENDING = "Pending"
    @@COMPLETED = "Completed"
    @@FAILED = "Failed"
    @@NO_ACTION = "No action"

    attr_reader :reference_container, :status, :message

    def initialize(args)
      @reference_container = args[:reference_container]

      @status = Action.PENDING
      @message = ""
    end

    def process
      raise "#{self.class}: method #{__method__} must be implemented for #{@reference_action_def.to_s}."
    end

    def link_markup(descr = nil)
      descr = "View resource." if descr == nil

      link = @reference_action_def.link
      embed_markup = "<a href=\"#{link}\" target=\"_blank\">#{descr}</a>"
      embed_markup
    end

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
      emb_fragment
    end

    def default_container(container = 'div')
      return @reference_node.document.create_element(container, :class => "default-media-display")
      #return @reference_node.document.create_element(container, :class => "no-default-media-display")
    end

    def embed_container(container = 'div')
      container = @reference_node.document.create_element(container, :class => "enhanced-media-display")
      container
    end

    def to_s
      return "#{@status}: #{self.class}, #{@reference_action_def.to_s}"
    end

    def self.find_caption(container)
      caption = container.xpath(".//*[local-name()='figcaption' or @class='figcap' or @class='figh']")
      return caption
    end

    def self.COMPLETED
      @@COMPLETED
    end

    def self.PENDING
      @@PENDING
    end

    def self.NO_ACTION
      @@NO_ACTION
    end

    def self.FAILED
      @@FAILED
    end
  end
end