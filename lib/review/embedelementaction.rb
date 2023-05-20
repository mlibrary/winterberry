module UMPTG::Review

  # Class that inserts resource embed viewer markup into
  # XML content (image, video, audio).
  class EmbedElementAction < NormalizeAction

    RESOURCE_EMBED_MARKUP = <<-REMARKUP
    <link href="%s/downloads/%s?file=embed_css" rel="stylesheet" type="text/css"/>
    <div id="fulcrum-embed-outer-%s">
    <div id="fulcrum-embed-inner-%s">
    <iframe id="fulcrum-embed-iframe-%s" src="%s" title="%s" allowfullscreen="true"/>
    </div>
    </div>
    REMARKUP

    def initialize(args = {})
      super(args)
      @manifest = @properties[:manifest]
    end

    def process()
      resource_path = @properties[:resource_path]

=begin
      if reference_container.node_name == "p"
        # Not sure about this. epubcheck complains about ./span/div
        # so, attempt to convert the 'p' to 'div'.
        # See how this goes.
        reference_container.node_name = "div"
      end
=end

      # Retrieve the resource embed markup from the
      # Fulcrum resource metadata.
      emb_fragment = embed_fragment(resource_path)
      if emb_fragment.nil?
        @status = Action.FAILED
        return
      end

      # Insert new resource XML markup that will embed the
      # resource when viewed in the Fulcrum reader.
      emb_container = embed_container()
      emb_container.add_child(emb_fragment)

      # May have an issue if the img_node has @{id,style,class}
      # Wrap a div around both containers and add these attrs?
=begin
      puts "#{__method__}:parent=#{reference_node.parent.name}"
      if reference_node.parent.name == 'div'
        def_container = reference_node.parent
      else
        def_container = default_container
        reference_node.add_next_sibling(def_container)
        def_container.add_child(reference_node)
      end
=end

      case reference_node.name
      when 'img'
        # Wrap the current resource XML markup with a container
        # that allows it to be visible when not in the Fulcrum reader.
        def_container = default_container()
        reference_node.add_next_sibling(def_container)
        def_container.add_child(reference_node)
        def_container.add_next_sibling(emb_container)
      when 'figure'
        figcaption_node = reference_node.xpath("./*[local-name()='figcaption']").first
        if figcaption_node.nil?
          reference_node.add_child(emb_container)
        else
          figcaption_node.add_previous_sibling(emb_container)
        end
        reference_node.remove_attribute("data-fulcrum-embed-filename")
        # Setting this didn't seem to work. Got double resources embedded.
        #reference_node["data-fulcrum-embed"] = false
        reference_node.remove_attribute("style")
      else
        raise "embed for element #{reference_node.name} not implemented"
      end

=begin
      # TODO: add option for this? For globally enhanced
      # EPUBs, remove the default container leaving only
      # the enhanched container.
      def_container.remove
=end

      # Action completed.
      @status = NormalizeAction.NORMALIZED
    end

=begin
    # Method generates XML markup to link a resource.
    #
    # Parameter:
    #   descr           Text to include within the link
    def link_markup(descr = nil)
      descr = "View resource." if descr == nil

      link = @reference_action_def.doi
      link = @reference_action_def.link if link.empty?
      return "<a href=\"#{link}\" target=\"_blank\">#{descr}</a>"
    end
=end

    # Method generates the XML markup for embedding
    # a specific resource.
    def embed_fragment(resource_path)
      fileset = @manifest.fileset(resource_path)
      #emb_markup = fileset["embed_code"] unless fileset["noid"].empty?
      noid = fileset["noid"]
      emb_markup = ""
      unless noid.empty?
        embed_markup = fileset['embed_code']
        unless embed_markup.nil? or embed_markup.empty?
          embed_doc = Nokogiri::XML::DocumentFragment.parse(embed_markup)
          iframe_node = embed_doc.xpath("descendant-or-self::*[local-name()='iframe']").first
          embed_link = iframe_node['src']
        end

        link_uri = URI(embed_link)
        link_scheme_host = link_uri.scheme + "://" + link_uri.host

        href = fileset['link'][12..-3]
        title = fileset['title'].nil? ? "" : fileset['title']

        emb_markup = sprintf(RESOURCE_EMBED_MARKUP, link_scheme_host, noid, noid, noid, noid, embed_link, title)
      end

      if emb_markup.nil? or emb_markup.strip.empty?
        @message = "Warning: no embed markup for resource node #{resource_path}"
        return nil
      end

      emb_fragment = Nokogiri::XML.fragment(emb_markup)
      if emb_fragment.nil?
        @message = "Warning: error creating embed markup document for resource node #{resource_path}"
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
      return @reference_node.document.create_element(container, :class => "enhanced-media-display")
    end
  end
end
