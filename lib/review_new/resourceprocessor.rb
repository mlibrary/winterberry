module UMPTG::Review

  # Class processes each resource reference found within XML content.
  class ResourceProcessor < EntryProcessor

    # Processing parameters:
    #   :selector               Class for selecting resource references
    #   :logger                 Log messages
    def initialize(args = {})
      args[:selector] = ResourceReferenceSelector.new
      super(args)
    end

    def new_action(args = {})
      case @selector.reference_type(args[:reference_node])
      when :element
        list = ResourceProcessor.image_reference_actions(args)
      when :marker
        list = [
              NormalizeMarkerAction.new(args)
            ]
      else
        list = super(args)
      end
      return list
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
        # Normalize image parent, as it may be a <p>
        # and needs to be a <div> so markup may be inserted.
        img_container_list = reference_node.xpath("./ancestor::*[local-name()='p']")
        img_container_list.each do |node|
          action_list << NormalizeImageContainerAction.new(
                   name: name,
                   reference_node: reference_node,
                   action_node: node
               )
        end

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
