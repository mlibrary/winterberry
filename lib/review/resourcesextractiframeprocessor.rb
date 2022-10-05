module UMPTG::Review

  # Class processes each resource reference found within XML content.
  class ResourcesExtractIframeProcessor < EntryProcessor
    attr_accessor :manifest

    RESOURCE_REFERENCE_XPATH = <<-SXPATH
    //*[
    local-name()='head'
    ]/*[
    local-name()='link'
    and contains(@href,'fulcrum_default.css')
    ]|
    //*[
    local-name()='iframe'
    ]
    SXPATH

    # Processing parameters:
    #   :selector               Class for selecting resource references
    #   :logger                 Log messages
    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: RESOURCE_REFERENCE_XPATH
            )
      super(args)
      @manifest = nil
    end

    def action_list(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      reference_action_list = []
      unless @selector.nil? or xml_doc.nil?
        reference_list = @selector.references(xml_doc)
        reference_list.each do |reference_node|
          case @selector.reference_type(reference_node)
          when :element
            if reference_node.name == 'link'
              reference_action_list << RemoveElementAction.new(
                          name: name,
                          reference_node: reference_node,
                          action_node: reference_node
                        )
              next
            end

            node_list = reference_node.xpath("./ancestor::*[local-name()='div' and contains(concat(' ',@class,' '),'fig')][1]")
            if node_list.empty?
              reference_action_list << Action.new(
                        name: name,
                        reference_node: reference_node,
                        warning_message: "#{reference_node.name}: #{reference_node['src']} has no 'fig' container."
                      )
            else
              action_node = node_list.first
              src = reference_node['src']
              reference_action_list << Action.new(
                        name: name,
                        reference_node: reference_node,
                        action_node: action_node,
                        info_message: "#{reference_node.name}: #{src} 'fig' container found."
                      )
              noid = src.rpartition('.').last
              unless noid.nil?
                fileset = @manifest.fileset_from_noid(noid)
                unless fileset['noid'].empty?
                  reference_action_list << NormalizeFigureIframeAction.new(
                            name: name,
                            reference_node: reference_node,
                            action_node: action_node,
                            file_name: fileset['file_name']
                          )
                end
              end
=begin
              reference_action_list << RemoveElementMediaAction.new(
                        name: name,
                        reference_node: reference_node,
                        action_node: action_node
                      )

              if action_node.parent.name == "p"
                reference_action_list << Action.new(
                          name: name,
                          reference_node: reference_node,
                          warning_message: "#{reference_node.name}: : #{reference_node['src']} container is a p element."
                        )
              else
                reference_action_list << RenameElementAction.new(
                          name: name,
                          reference_node: reference_node,
                          action_node: action_node.parent
                        )
              end

              node_list = node_list.first.xpath("./following-sibling::*[local-name()='div' and contains(concat(' ',@class,' '),' enhanced-media-display ')][1]")
              if node_list.empty?
                reference_action_list << Action.new(
                          name: name,
                          reference_node: reference_node,
                          warning_message: "image: #{reference_node['src']} has no enhanced display."
                        )
              else
                reference_action_list << RemoveElementAction.new(
                          name: name,
                          reference_node: reference_node,
                          action_node: node_list.first
                        )
              end
=end
            end
          when :marker
            reference_action_list << RemoveMarkerMediaAction.new(
                      name: name,
                      reference_node: reference_node
                    )
          end
        end
      end

      # Return the list of Actions which contains the status
      # for each.
      return reference_action_list
    end
  end
end
