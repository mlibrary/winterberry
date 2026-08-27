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

    def initialize(process, options: {})
    puts process.class.name
      super(
              process,
              :jats_resource,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(issue, options: options)

      reference_node = issue.content

      fig_node = reference_node.xpath("ancestor-or-self::*[local-name()='fig'][1]").first
      if fig_node.nil?
        issue.actions << UMPTG::XML::Pipeline::Action.new(
              issue,
              options: {
                      warning_message: "#{@name}, no figure container for link #{reference_node['xlink:href']}. Skipping."
                  }
            )
        return
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
        issue.actions << UMPTG::XML::Pipeline::Action.new(
              issue,
              options: {
                      warning_message: "#{@name}, no HREF found for reference #{reference_node}. Skipping."
                  }
            )
        return
      end

      fileset = nil
      unless @resource_map.nil?
        resource = process.resource_map.reference_resource(href)
        unless resource.nil?
          action << UMPTG::XML::Pipeline::Action.new(
                issue,
                options: {
                        info_message: "#{@name}, mapped #{href} to #{resource.name}."
                    }
              )

          fileset = process.manifest.fileset(resource.name)
          if fileset['noid'].empty?
            action.add_warning_msg("#{@name}, no fileset found for #{resource.name}. Skipping.")
          end
          issue.actions << action
        end
      end
      fileset = process.manifest.fileset(href) if fileset.nil?
      fileset = process.manifest.fileset_from_noid(href) if fileset['noid'].empty?

      if fileset['noid'].empty?
        issue.actions << UMPTG::XML::Pipeline::Action.new(
              issue,
              options: {
                      warning_message: "#{@name}, no fileset for href #{href}. Skipping."
                  }
            )
        return
      end

      caption_node = fig_node.xpath("./*[local-name()='caption']").first
      caption_markup = caption_node.nil? ? nil : caption_node.inner_html
      jats_media_markup = process.manifest.fileset_embed_jats_markup(
                  file_name: fileset['file_name'],
                  ableplayer_sign_file_name: fig_node['data-fulcrum-ableplayer-sign-file-name'],
                  ableplayer_present_file_name: fig_node['data-fulcrum-ableplayer-present-file-name'],
                  ableplayer_present_sign_file_name: fig_node['data-fulcrum-ableplayer-present-sign-file-name'],
                  ableplayer_vtt_file_name: fig_node['data-fulcrum-ableplayer-vtt-file-name'],
                  ableplayer_vtt_lang: fig_node['data-fulcrum-ableplayer-vtt-lang'],
                  caption_markup: caption_markup,
                  figure_id: fig_node['id'],
                  renderer: UMPTG::Journal::JATSRenderer.new
                )
      unless jats_media_markup.strip.empty?
        issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                issue,
                options: {
                    action: :replace_node,
                    markup: jats_media_markup,
                    info_message: "found fileset #{fileset['file_name']}."
                  }
              )
      end
    end
  end
end
