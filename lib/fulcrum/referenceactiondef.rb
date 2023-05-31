module UMPTG::Fulcrum

  # Class defines the Action for a specific resource reference.
  # It contains the type of action (embed|link) and the Fulcrum
  # metadata for the resource.
  class ReferenceActionDef < UMPTG::Object
    attr_reader :resource_metadata

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

      @resource_map_action = @properties[:resource_map_action]
      @resource_metadata = @properties[:resource_metadata]
    end

    # Resource reference name.
    def reference_name
      return @resource_map_action.reference.name
    end

    # Resource name.
    def resource_name
      return @resource_map_action.resource.name unless @resource_map_action.resource.nil?
    end

    # String for the assigned action type.
    def action_str
      return @resource_map_action.type
    end

    # Resource embed markup.
    def embed_markup
      return @resource_metadata['embed_code'] unless @resource_metadata.nil?
    end

    def fileset_embed_markup
      noid = @resource_metadata["noid"]
      embed_markup = ""
      unless noid.empty?
        # Found fileset. Determine the embed link from the
        # "Embed Code" property. This will give the correct host.
        # If fileset has no property, then it can't be embedded.
        fmarkup = @resource_metadata['embed_code']
        unless fmarkup.nil? or fmarkup.empty?
          embed_doc = Nokogiri::XML::DocumentFragment.parse(fmarkup)
          iframe_node = embed_doc.xpath("descendant-or-self::*[local-name()='iframe']").first
          embed_link = iframe_node['src']
          ititle = iframe_node['title']
          title = HTMLEntities.new.encode(ititle)

          href = @resource_metadata['link'][12..-3]
          #title = fileset['title'].nil? ? "" : fileset['title']

          link_uri = URI(embed_link)
          link_scheme_host = link_uri.scheme + "://" + link_uri.host

          embed_markup = sprintf(RESOURCE_EMBED_MARKUP, link_scheme_host, noid, noid, noid, noid, embed_link, title)
        end
      end
      return embed_markup
    end

    # Resource type.
    def resource_type
      return @resource_metadata.nil? ? "" : @resource_metadata['resource_type']
    end

    # Resource Fulcrum link path.
    def link
      unless @resource_metadata.nil? or @resource_metadata['link'].nil?
        link_data = @resource_metadata['link']
        link = link_data.match('^[^\(]+\(\"([^\"]+)\".*') {|m| m[1] }
        return link
      end
      return ""
    end

    # Resource Fulcrum link path.
    def doi
      #doi = @resource_metadata.nil? ? "" : @resource_metadata['doi']
      #return doi unless doi.nil? or doi.strip.empty?
      return ""
    end

    # Resource alternative text.
    def alt_text
      return @resource_metadata['alternative_text'] unless @resource_metadata.nil?
    end

    # Generate a string for this definition.
    def to_s
      return "#{action_str}: #{reference_name} => #{resource_name}"
    end
  end
end
