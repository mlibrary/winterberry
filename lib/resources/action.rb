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

  def link_markup(metadata, descr = nil)
    descr = "View resource." if descr == nil

    link = metadata['link']
    link = link.match('^[^\(]+\(\"([^\"]+)\".*') {|m| m[1] }
    embed_markup = "<a href=\"#{link}\" target=\"_blank\">#{descr}</a>"
    embed_markup
  end

  def embed_fragment
    resource_action = @action_args[:resource_action]
    emb_markup = resource_action['embed_code']
    if emb_markup == nil or emb_markup.strip.empty?
      resource_node = @action_args[:resource_node]
      @message = "Warning: no embed markup for resource node #{resource_node}"
      return nil
    end

    emb_fragment = Nokogiri::XML.fragment(emb_markup)
    if emb_fragment == nil
      resource_node = @action_args[:resource_node]
      @message = "Warning: error creating embed markup document for resource node #{resource_node}"
    end
    emb_fragment
  end

  def default_container
    img_node = @action_args[:resource_img]
    container = img_node.document.create_element("div", :class => "default-media-display")
    container
  end

  def embed_container
    img_node = @action_args[:resource_img]
    container = img_node.document.create_element("div", :class => "enhanced-media-display")
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