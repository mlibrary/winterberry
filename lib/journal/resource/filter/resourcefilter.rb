module UMPTG::Journal::Resource::Filter

  class ResourceFilter < UMPTG::XML::Pipeline::Filter

    attr_reader :manifest

    XPATH = <<-SXPATH
    //*[
    local-name()='graphic'
    and @*
    ] |
    //*[
    local-name()='fig'
    and @data-fulcrum-embed-filename
    ]
    SXPATH

    def initialize(args = {})
      args[:name] = :resource
      args[:xpath] = XPATH

      super(args)

      @manifest = @properties[:manifest]
      @logger = @properties[:logger]
      @resource_map = @properties[:resource_map]
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]

      actions = []

      fig_node = reference_node.xpath("ancestor-or-self::*[local-name()='fig'][1]").first
      if fig_node.nil?
        @logger.warn("no figure container for link #{reference_node['xlink:href']}.")
        return actions
      end

      href = fig_node['data-fulcrum-embed-filename']
      if href.nil?
        # Nokogiri having problems with namespaces?
        # Can't find attribute xlink:href via hash.
        reference_node.attributes.each do |k,v|
          if k == "xlink:href"
            href = v
            break
          end
        end
      end
      if href.nil?
        @logger.warn("no HREF found for reference #{reference_node}. Skipping.")
        return actions
      end

      fileset = nil
      unless @resource_map.nil?
        resource = @resource_map.reference_resource(href)
        unless resource.nil?
          @logger.info("mapped #{href} to #{resource.name}.")
          fileset = manifest.fileset(resource.name)
          if fileset['noid'].empty?
            @logger.warn("no fileset found for #{resource.name}.")
          end
        end
      end
      fileset = manifest.fileset(href) if fileset.nil?
      fileset = manifest.fileset_from_noid(href) if fileset['noid'].empty?

      if fileset['noid'].empty?
        @logger.warn("no fileset for href #{href}. Skipping.")
        return actions
      end
      @logger.info("found fileset #{fileset['file_name']}.")

      caption_node = fig_node.xpath("./*[local-name()='caption']").first
      caption_markup = caption_node.nil? ? nil : caption_node.inner_html
      jats_media_markup = @manifest.fileset_embed_jats_markup(
                  file_name: fileset['file_name'],
                  caption_markup: caption_markup,
                  renderer: UMPTG::Journal::JATSRenderer.new
                )
      unless jats_media_markup.strip.empty?
        actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                reference_node: reference_node,
                action: :replace_node,
                markup: jats_media_markup
              )
      end
      return actions
    end
  end
end
