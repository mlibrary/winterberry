require 'nokogiri'

class Action
  @@PENDING = "Pending"
  @@COMPLETED = "Completed"
  @@FAILED = "Failed"
  @@NO_ACTION = "No action"

  attr_reader :status, :message

  def initialize(args)
    @action_args = args

    @resource_action = args[:resource_action]

    @status = Action.PENDING
    @message = ""
  end

  def process
    raise "#{self.class}: method #{__method__} must be implemented."
  end

  def resource_action
    return @action_args[:resource_action]
  end

  def resource
    return @action_args[:resource]
  end

  def resource_img
    return @action_args[:resource_img]
  end

  def link_markup(metadata, descr = nil)
    descr = "View resource." if descr == nil

    link = metadata['link']
    embed_markup = "<a href=\"#{link}\" target=\"_blank\">#{descr}</a>"
    embed_markup
  end

  def embed_fragment
    resource_action = @action_args[:resource_action]
    emb_markup = resource_action.embed_markup
    if emb_markup == nil or emb_markup.strip.empty?
      file_name = resource_action.reference
      @message = "Warning: no embed markup for resource node #{file_name}"
      return nil
    end

    emb_fragment = Nokogiri::XML.fragment(emb_markup)
    if emb_fragment.nil?
      file_name = resource_action.reference
      @message = "Warning: error creating embed markup document for resource node #{file_name}"
    end
    emb_fragment
  end

  def default_container(container = 'div')
    img_node = @action_args[:resource_img]
    container = img_node.document.create_element(container, :class => "default-media-display")
    container
  end

  def embed_container(container = 'div')
    img_node = @action_args[:resource_img]
    container = img_node.document.create_element(container, :class => "enhanced-media-display")
    container
  end

  def to_s
    resource_action = @action_args[:resource_action]
    return "#{@status}: #{self.class}, #{resource_action.to_s}"
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