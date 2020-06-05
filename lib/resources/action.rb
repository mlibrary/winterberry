require 'nokogiri'

class Action
  @@PENDING = "Pending"
  @@COMPLETED = "Completed"
  @@FAILED = "Failed"

  attr_reader :status, :message

  def initialize(args)
    @action_args = args
    @status = @@PENDING
    @message = ""
  end

  def resource_action
    @action_args[:resource_action]
  end

  def link_markup(metadata, descr = nil)
    descr = "View resource." if descr == nil

    link = metadata['link']
    embed_markup = "<a href=\"#{link}\" target=\"_blank\">#{descr}</a>"
    embed_markup
  end

  def embed_fragment
    #resource_action = @action_args[:resource_action]
    #emb_markup = resource_action['embed_code']
    resource_metadata = @action_args[:resource_metadata]
    emb_markup = resource_metadata['embed_code']
    if emb_markup == nil or emb_markup.strip.empty?
      file_name = resource_metadata['file_name']
      @message = "Warning: no embed markup for resource node #{file_name}"
      return nil
    end

    emb_fragment = Nokogiri::XML.fragment(emb_markup)
    if emb_fragment.nil?
      file_name = resource_metadata['file_name']
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

  def element_action_to_s
    action = @action_args[:resource_action]
    return "#{@status}: #{self.class}, #{action['resource_action']}: #{action['file_name']} => #{action['resource_name']}"
  end

  def marker_action_to_s
    action = @action_args[:resource_action]
    return "#{@status}: #{self.class}, #{action['resource_action']}: #{action['resource_name']}"
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

  def self.FAILED
    @@FAILED
  end
end