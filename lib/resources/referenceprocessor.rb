module UMPTG::Resources

  require 'nokogiri'

  class ReferenceProcessor

    # XPath expression for retrieving resource references
    # within an XML document.
    #
    # References of type :marker are refer to resources
    # that are not contained within the EPUB and appear
    # only in the Fulcrum version. These are usually
    # wrapped within the markup
    #
    #    <p|div class="rb|rbi">
    #
    # References of type :element refer to resources
    # that are contained within the EPUB and are
    # replaced with a resource in the Fulcrum version,
    # while maintaining the original reference for
    # use by other readers. The markup for these are either
    #
    #    <p class="fig"><img src="reference"/></p>
    # or
    #    <figure><img src="reference"/></figure>
    #
    # One expression is used to capture all references
    # so they can be processed in the order they appear
    # in the document.
  @@SELECTION_XPATH = <<-SXPATH
  //*[
  (local-name()='p' and @class='fig')
  or (local-name()='div' and @class='figurewrap')
  or (local-name()='figure' and count(*[local-name()='p' and @class='fig'])=0)
  or @class='rb'
  or @class='rbi'
  ]
  SXPATH

    def reference_actions(args = {})
      xml_doc = args[:xml_doc]
      raise "Error: XML document must be specified." if xml_doc.nil?

      reference_action_defs = args[:reference_action_defs]
      raise "Error: reference action definitions must be specified." \
            if reference_action_defs.nil?

      # Retrieve the resource references from this document.
      reference_container_list = xml_doc.xpath(@@SELECTION_XPATH)

      # For each reference found, create the appropriate action
      # to process the reference. A reference may be type
      # :element or :marker
      reference_action_list = []
      reference_container_list.each do |refnode|
        case ReferenceProcessor.reference_type(refnode)
        when :element
          list = element_reference_actions(
                      :reference_container => refnode,
                      :reference_action_defs => reference_action_defs
                    )
        when :marker
          list = marker_reference_actions(
                      :reference_container => refnode,
                      :reference_action_defs => reference_action_defs
                    )
        else
          next
        end
        reference_action_list += list
      end
      return reference_action_list
    end

    private

    def element_reference_actions(args = {})
      reference_container = args[:reference_container]
      reference_action_defs = args[:reference_action_defs]

      node_list = reference_container.xpath(".//*[local-name()='img']")

      reference_action_list = []
      node_list.each do |node|
        src_attr = node.attribute("src")
        next if src_attr.nil?

        spath = src_attr.value.strip
        reference_action_def_list = reference_action_defs[spath]
        if reference_action_def_list.nil?
          puts "Warning: reference #{spath} has no action definition."
          next
        end

        args = {
                  :reference_container => reference_container,
                  :reference_node => node
              }

        reference_action_def_list.each do |reference_action_def|
          args[:reference_action_def] = reference_action_def

          case reference_action_def.action_str
          when "embed"
            case reference_action_def.resource_type
            when 'interactive map'
              reference_action = EmbedMapAction.new(args)
            else
              reference_action = EmbedElementAction.new(args)
            end
          when "link"
            reference_action = LinkElementAction.new(args)
          when "remove"
            reference_action = RemoveElementAction.new(
                                :reference_action_def => reference_action_def,
                                :reference_container => reference_container,
                                :reference_node => node
                              )
          when "none"
            reference_action = NoneAction.new(args)
          else
            puts "Warning: invalid element action #{reference_action.to_s}"
            next
          end
          reference_action_list << reference_action
        end
      end
      return reference_action_list
    end

    def marker_reference_actions(args = {})
      reference_container = args[:reference_container]
      reference_action_defs = args[:reference_action_defs]

      # Return the nodes that reference resources.
      # For marker callouts, this should be within
      # a XML comment, but not always the case.
      # NOTE: either display warning if no comment,
      # or just use the node content?
      node_list = reference_container.xpath(".//comment()")
      node_list = [ reference_container ] if node_list.nil? or node_list.empty?

      reference_action_list = []
      node_list.each do |node|
        path = node.text.strip

        reference_action_def_list = reference_action_defs[path]
        if reference_action_def_list.nil?
          puts "Warning: marker #{path} has no action definition."
          next
        end

        args = {
                  :reference_container => reference_container,
                  :reference_node => node
              }
        reference_action_def_list.each do |reference_action_def|
          args[:reference_action_def] = reference_action_def

          case reference_action_def.action_str
          when "embed"
            reference_action = EmbedMarkerAction.new(args)
          when "link"
            reference_action = LinkMarkerAction.new(args)
          when "none"
            reference_action = NoneAction.new(args)
          else
            puts "Warning: invalid marker action #{reference_action_def.action_str}"
            reference_action = nil
          end

          reference_action_list << reference_action unless reference_action.nil?
        end
      end
      return reference_action_list
    end

    def self.reference_type(node)
      attr = node.attribute("class")
      unless attr.nil?
        attr = attr.text.downcase
        return :marker if attr == "rb" or attr == "rbi"
      end
      return :element
    end
  end
end
