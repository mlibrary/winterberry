module UMPTG::Review

  # Class processes each resource reference found within XML content.
  class ResourceProcessor < UMPTG::EPUB::EntryProcessor

    @@reference_selector = nil

    # Processing parameters:
    #   :default_action         Default resource action, embed|link|none
    #   :resource_metadata      Monograph resource metadata
    #   :resource_map           Resource reference to fileset mapping
    #   :selector               Class for selecting resource references
    #   :logger                 Log messages
    def initialize(args = {})
      super(args)

      @default_action = @properties[:default_action]
      @resource_metadata = @properties[:resource_metadata]
      @resource_map = @properties[:resource_map]
      @selector = @properties[:selector]
      @logger = @properties[:logger]

      @reference_action_defs = nil
    end

    # Method generates and processes a list of actions
    # for the specified XML content.
    #
    # Parameters:
    #   :name         Identifier associated with XML content
    #   :xml_doc      XML content document.
    def action_list(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      @@reference_selector = ResourceReferenceSelector.new if @@reference_selector.nil?
      reference_list = @@reference_selector.references(xml_doc)

      # For each reference element, determine the necessary actions.
      reference_action_list = []
      reference_list.each do |refnode|
        case @@reference_selector.reference_type(refnode)
        when :element
          list = ResourceProcessor.image_reference_actions(
                  name: name,
                  reference_node: refnode
                )
        when :marker
          list = [
                NormalizeMarkerAction.new(
                      name: name,
                      reference_node: refnode
                    )
              ]
        else
          # Shouldn't happen
          next
        end

        reference_action_list += list
      end

      # Process all the Actions for this XML content.
      reference_action_list.each do |action|
        action.process()
      end

      # Return the list of Actions which contains the status
      # for each.
      return reference_action_list
    end

    private

    @@FIGURE_XPATH = <<-FXPATH
    ./ancestor::*[
    local-name()='figure'
    ][1]
    FXPATH

    @@DIV_XPATH = <<-DXPATH
    ./ancestor::*[
    (local-name()='div' and @class='figurewrap')
    ][1]
    DXPATH

    @@IMGCAPTION_XPATH = <<-ICXPATH
    .//*[
    local-name()='img'
    or local-name()='figcaption'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figh'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='image_caption'
    or starts-with(translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'figcap')
    ]
    ICXPATH

    def self.image_reference_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]

      action_list = []
      action_list << ImageAction.new(
                 name: args[:name],
                 reference_node: reference_node
             )

      # Normalize figure container, if possible.
      container_list = reference_node.xpath(@@FIGURE_XPATH)
      if container_list.empty?
        container_list = reference_node.xpath(@@DIV_XPATH)
        if container_list.empty?
          action_list << Action.new(
                   name: name,
                   reference_node: reference_node
               )
          action_list.last.add_warning_msg("Image:  #{reference_node['src']} unable to determine container")
        else
          action_list << NormalizeFigureAction.new(
                   name: name,
                   reference_node: reference_node,
                   action_node: container_list.first
               )
        end
      else
        action_list << Action.new(
                 name: name,
                 reference_node: reference_node
             )
        action_list.last.add_info_msg("Image:  #{reference_node['src']} has figure as parent")
      end

      # Normalize figure caption, if possible. Figure may contain
      # multiple images. Match captions to images.
      unless container_list.empty?
        container_node = container_list.first

        img_caption_list = container_node.xpath(@@IMGCAPTION_XPATH)
        raise "container image caption list is empty" if img_caption_list.empty?

        caption_node = nil
        if img_caption_list.first.name == 'img'
          # Assume caption after image.
          img_found = false
          img_caption_list.each do |node|
            next unless img_found or reference_node == node
            img_found = true
            unless node.name == 'img'
              caption_node = node
              break
            end
          end
        else
          # Assume caption before image.
          img_found = false
          img_caption_list.each do |node|
            caption_node = node unless node.name == 'img'
            break if reference_node == node
          end
        end

        if caption_node.nil?
          action_list << Action.new(
                   name: name,
                   reference_node: reference_node
               )
          action_list.last.add_warning_msg("Image:  #{reference_node['src']} unable to determine caption")
        elsif caption_node.name == 'figcaption'
          action_list << Action.new(
                   name: name,
                   reference_node: reference_node
               )
          action_list.last.add_info_msg("Image:  #{reference_node['src']} has a figure caption.")
        else
          action_list << NormalizeFigureCaptionAction.new(
                   name: name,
                   reference_node: reference_node,
                   action_node: caption_node
               )
        end
      end

      return action_list
    end
  end
end
