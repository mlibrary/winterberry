module UMPTG::Review

  # Class processes each resource reference found within XML content.
  class ResourceProcessor < EntryProcessor

    RESOURCE_REFERENCE_XPATH = <<-SXPATH
    //*[
    local-name()='img'
    or @class='rb'
    or @class='rbi'
    ]|
    //comment()[
    starts-with(translate(normalize-space(.),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'insert ')
    ]
    SXPATH

    attr_reader :resource_path_list

    # Processing parameters:
    #   :selector               Class for selecting resource references
    #   :logger                 Log messages
    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: RESOURCE_REFERENCE_XPATH
            )
      super(args)

      @resource_path_list = {}
    end

    def new_action(args = {})
      case @selector.reference_type(args[:reference_node])
      when :element
        list = image_reference_actions(args)
      when :marker
        list = marker_reference_actions(args)
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

    @@FIGUREDIV_XPATH = <<-FDXPATH
    ./ancestor::*[
    local-name()='figure'
    or (local-name()='div' and @class='figurewrap')
    ][1]
    FDXPATH

    @@IMGCAPTION_XPATH = <<-ICXPATH
    .//*[
    local-name()='img'
    or local-name()='figcaption'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figh'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='image_caption'
    or starts-with(translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'figcap')
    ]
    ICXPATH

    @@CAPTION_XPATH = <<-CXPATH
    .//*[
    local-name()='figcaption'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figh'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='image_caption'
    or starts-with(translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'figcap')
    ]
    CXPATH

    @@IMG_XPATH = <<-IXPATH
    .//*[
    local-name()='img'
    ]
    IXPATH


    def image_reference_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]

      resource_path = reference_node.key?('src') ? reference_node['src'] : "unspecified"
      if @resource_path_list[name].nil?
        @resource_path_list[name] = [ resource_path ]
      else
        @resource_path_list[name] << resource_path
      end

      xpath_base = "//*[local-name()='img' and @src='#{resource_path}']"

      action_list = []

      action_list << ImageAction.new(
                 name: name,
                 reference_node: reference_node,
                 resource_path: resource_path
             )
      ResourceProcessor.add_filename_spaces_msg(action_list.last, resource_path)

      # Normalize figure container, if possible.
      container_list = reference_node.xpath(@@FIGURE_XPATH)
      if container_list.empty?
        container_list = reference_node.xpath(@@DIV_XPATH)
        if container_list.empty?
          action_list << Action.new(
                   name: name,
                   reference_node: reference_node,
                   warning_message: "image: \"#{resource_path}\" unable to determine container element."
               )
        else
          action_list << NormalizeFigureAction.new(
                   name: name,
                   reference_node: reference_node,
                   resource_path: resource_path,
                   xpath: xpath_base + "/" + @@DIV_PATH,
                   action_node: container_list.first
               )
        end
      else
        action_list << Action.new(
                 name: name,
                 reference_node: reference_node,
                 info_message: "image: \"#{resource_path}\" has #{container_list.first.name} as container element."
             )
      end

      unless container_list.empty?
        container_node = container_list.first
        img_container_list = reference_node.xpath("./ancestor::*[local-name()='p' or local-name()='div']")

        # Determine how many img elements are within container.
        # If 1 then normalize the container. Otherwise, let
        # nest action handle this case.
        container_img_list = container_node.xpath(".//*[local-name()='img']")

        if container_img_list.count == 1
          # Normalize image parent, as it may be a <p>
          # and needs to be a <div> so markup may be inserted.
          img_container_list.each do |node|
            action_list << NormalizeImageContainerAction.new(
                     name: name,
                     reference_node: reference_node,
                     resource_path: resource_path,
                     xpath: xpath_base + "/ancestor::*[local-name()='p' or local-name()='div']",
                     action_node: node,
                     #warning_message: "image: \"#{resource_path}\" has #{node.name} as container element for image element. Recommended is either no container element or use div element."
                     warning_message: "image: \"#{resource_path}\" has #{node.name} as container element for image element. Recommended is either no container element."
                 )
          end
        end

        # Normalize figure caption, if possible. Figure may contain
        # multiple images. Match captions to images.
        caption_node = nil
        caption_list = container_node.xpath(@@CAPTION_XPATH)
        case
        when caption_list.empty?
          # No caption found.
          action_list << Action.new(
                   name: name,
                   reference_node: reference_node,
                   warning_message: "image: \"#{resource_path}\" unable to determine caption element."
               )
        when caption_list.count == 1
          # One caption found.
          caption_node = caption_list.first
          action_list << Action.new(
                   name: name,
                   reference_node: reference_node,
                   info_message: "image: \"#{resource_path}\" has #{caption_node.name} as caption element. Recommended element is figcaption."
               )
        else
          # Multiple captions found.
          # Determine if the number of images equals number
          # of captions. If not, report an error.
          # If so, then wrap the image and its caption
          # within a nested <figure>.
          img_list = container_node.xpath(@@IMG_XPATH)
          if caption_list.count == img_list.count
            # Counts match.
            container_caption_list = container_node.xpath(@@IMGCAPTION_XPATH)
            if container_caption_list.first.name == 'img'
              # Assume caption after image.
              caption_node = reference_node.xpath("./following::*[local-name()='p'][1]").first
              caption_location = :caption_after
            else
              # Assume caption before image.
              caption_node = reference_node.xpath("./preceding::*[local-name()='p'][1]").first
              caption_location = :caption_before
            end

            if caption_node.nil?
              # No caption found.
              action_list << Action.new(
                       name: name,
                       reference_node: reference_node,
                       warning_message: "image: \"#{resource_path}\" unable to determine caption element from multiple."
                   )
            else
              # Found caption.
              action_list << Action.new(
                       name: name,
                       reference_node: reference_node,
                       info_message: "image: \"#{resource_path}\" has #{caption_node.name} as caption element. Recommended element is figcaption."
                   )
            end

            unless caption_node.nil? or img_container_list.empty?
              # Normalize by wrapping <figure> around image and caption
              action_list << NormalizeFigureNestAction.new(
                       name: name,
                       reference_node: reference_node,
                       resource_path: resource_path,
                       xpath: xpath_base,
                       caption_node: caption_node,
                       caption_location: caption_location,
                       reference_container_node: img_container_list.first
                   )
            end
          end
        end

        unless caption_node.nil? or  caption_node.name == 'figcaption'
          # Caption not a <figcaption>, normalize.
          action_list << NormalizeFigureCaptionAction.new(
                   name: name,
                   reference_node: reference_node,
                   resource_path: resource_path,
                   xpath: xpath_base.strip + "/" + @@FIGUREDIV_XPATH.strip + @@CAPTION_XPATH.strip,
                   action_node: caption_node
               )
        end
      end

      return action_list
    end

    def marker_reference_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]

      action_list = []
      if reference_node.key?("data-fulcrum-embed-filename") and !reference_node["data-fulcrum-embed-filename"].empty?
        resource_path = reference_node["data-fulcrum-embed-filename"]
        if @resource_path_list[name].nil?
          @resource_path_list[name] = [ resource_path ]
        else
          @resource_path_list[name] << resource_path
        end

        action_list << Action.new(
                 name: name,
                 reference_node: node
             )
        if reference_node.name == "figure"
          action_list.last.add_info_msg("marker: \"#{resource_path}\" has markup #{reference_node.to_xhtml}.")
        else
          action_list.last.add_warning_msg("marker: \"#{resource_path}\" has markup #{reference_node.to_xhtml}.")
        end
        ResourceProcessor.add_filename_spaces_msg(action_list.last, resource_path, false)
      else
        # Return the nodes that reference resources.
        # For marker callouts, this should be within
        # a XML comment, but not always the case.
        node_list = reference_node.xpath(".//comment()")
        node_list = [ reference_node ] if node_list.nil? or node_list.empty?
        node_list.each do |node|
          resource_path = node.text.strip

          #path = path.match(/insert[ ]+([^\>]+)/)[1]
          # Generally, additional resource references are expected
          # to use the markup:
          #     <p class="rb|rbi"><!-- resource_file_name.ext --></p>
          # But recently, Newgen has been using the markup
          #     <!-- <insert resource_file_name.ext> -->
          # So here we check for this case.
          r = resource_path.match(/insert[ ]+([^\>]+)/)
          unless r.nil?
            # Appears to be Newgen markup.
            resource_path = r[1]
          end
          if @resource_path_list[name].nil?
            @resource_path_list[name] = [ resource_path ]
          else
            @resource_path_list[name] << resource_path
          end

          action_list << Action.new(
                   name: name,
                   reference_node: node,
                   warning_message: "marker: \"#{resource_path}\" found and has #{node.name} as marker element. Recommended markup is <figure data-fulcrum-embed-filename=\"#{resource_path}\"]."
               )
          ResourceProcessor.add_filename_spaces_msg(action_list.last, resource_path, false)

          xpath = "//*[(@class='rb' or @class='rbi') and contains(normalize-space(.),'#{resource_path}')]|//comment()[starts-with(translate(normalize-space(.),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'insert ') and contains(normalize-space(.),'#{resource_path}')]"
          #node_list = reference_node.document.xpath(xpath)
          #puts "resource:#{resource_path},#{reference_node},#{node_list.count}"
          action_list << NormalizeMarkerAction.new(
                     name: name,
                     reference_node: reference_node,
                     resource_path: resource_path,
                     xpath: xpath
                  )
        end
      end
      return action_list
    end

    def self.add_filename_spaces_msg(action, resource_path, is_image = true)
      # Flag this reference if the file name contains spaces.
      type_txt = is_image ? "image" : "marker"
      if File.basename(resource_path).match?(/[ ]+/)
        action.add_warning_msg("#{type_txt}: \"#{resource_path}\" found and the name contains spaces.")
      else
        action.add_info_msg("#{type_txt}: \"#{resource_path}\" found.")
      end
    end
  end
end
