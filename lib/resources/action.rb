require 'nokogiri'

class Action
  def initialize(args)
    @action_args = args
  end

  def link_markup(metadata, descr = nil)
    descr = "View resource." if descr == nil

    link = metadata['link']
    link = link.match('^[^\(]+\(\"([^\"]+)\".*') {|m| m[1] }
    embed_markup = "<a href=\"#{link}\" target=\"_blank\">#{descr}</a>"
    embed_markup
  end

  def embed_fragment
    metadata = @action_args[:resource_metadata]

    emb_markup = metadata['embed_code']
    if emb_markup == nil or emb_markup.strip.empty?
      resource_node = @action_args[:resource_node]
      puts "Warning: no embed markup for resource node #{resource_node}"
      return
    end

    emb_fragment = Nokogiri::XML.fragment(emb_markup)
    if emb_fragment == nil
      resource_node = @action_args[:resource_node]
      puts "Warning: error creating embed markup document for resource node #{resource_node}"
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

end