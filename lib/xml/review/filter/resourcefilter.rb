module UMPTG::XML::Review::Filter

  class ResourceFilter < UMPTG::XML::Pipeline::Filter

    RESOURCE_REFERENCE_XPATH = <<-SXPATH
    //*[
    local-name()='figure'
    or (
    local-name()='p' and (@class='rb' or @class='rbi')
    ) or (
    (local-name()='p' or local-name()='div') and translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figurewrap'
    ) or (
    local-name()='img' and not(ancestor::*[local-name()='figure' or ((local-name()='p' or local-name()='div') and translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figurewrap')])
    )
    ]|
    //comment()[
    starts-with(translate(normalize-space(.),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'insert ')
    ]
    SXPATH

    IMGCONTAINER_XPATH = <<-ICOXPATHN
    ./ancestor::*[
    local-name()='p' or local-name()='div'
    ][1]
    ICOXPATHN

    @@IMGCAPTION_XPATH = <<-ICXPATH
    .//*[local-name()='img'
    or local-name()='figcaption'
    or (
    count(ancestor::*[local-name()='figcaption'])=0
    and (
    translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figh'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figh1'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='fign'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='image_caption'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figattrib'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figatr'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figpara'
    or starts-with(translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'figcap')
    or starts-with(translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'figcaption')
    or starts-with(translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'source')
    )
    )
    ]
    ICXPATH

    IMGPARENT_XPATH = <<-ICPXPATH
    ./ancestor::*[
    local-name()='figcaption'
    or (
    translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figh'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figh1'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='fign'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='image_caption'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figattrib'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figatr'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figpara'
    or starts-with(translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'figcap')
    or starts-with(translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'figcaption')
    or starts-with(translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'source')
    )
    ]
    ICPXPATH

    def initialize(args = {})
      args[:name] = :resources
      args[:selector] = UMPTG::XML::Review::ElementSelector.new(
              selection_xpath: RESOURCE_REFERENCE_XPATH
            )
      super(args)

      @resource_path_list = {}
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]

      @resource_path_list[name] = [] unless @resource_path_list.key?(name)
      reference_action_list = []

      case reference_node.name
      when "img"
        reference_action_list << ResourceFilter.add_image_action(args)

        resource_path = reference_node["src"]
        @resource_path_list[name] << resource_path

        reference_action_list << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 warning_message: "image: \"#{resource_path}\" unable to determine figure container element."
             )
      else
        if reference_node.key?("data-fulcrum-embed-filename")
          # Found an additional resource.
          resource_path = reference_node["data-fulcrum-embed-filename"].strip
          if resource_path.empty?
            # Give warning, but shouldn't be an issue.
            reference_action_list << UMPTG::XML::Pipeline::Action.new(
                     name: name,
                     reference_node: reference_node,
                     warning_message: "image: has element #{reference_node.name} as figure container and @data-fulcrum-embed-filename is empty."
                 )
          else
            @resource_path_list[name] << resource_path
            reference_action_list << UMPTG::XML::Pipeline::Action.new(
                     name: name,
                     reference_node: reference_node,
                     info_message: "image: \"#{resource_path}\" has element #{reference_node.name} as figure container and @data-fulcrum-embed-filename is set."
                 )
          end
        else
          # Traverse figure|div|p children looking for image(s) or caption(s).
          # NOTE: assumes caption(s) follow image(s).
          figure_obj_list = []
          if @selector.reference_type(reference_node) == :marker
            reference_action_list += marker_reference_actions(
                      name: name,
                      reference_node: reference_node,
                      figure_container: reference_node
                  )
          else
            container_child_list = reference_node.xpath(@@IMGCAPTION_XPATH)
            if container_child_list.empty?
              # Give warning, but shouldn't be an issue.
              reference_action_list << UMPTG::XML::Pipeline::Action.new(
                       name: name,
                       reference_node: reference_node,
                       warning_message: "image: has element #{reference_node.name} as figure container and is empty."
                   )
            else
              figure_obj = UMPTG::XML::Review::Figure.new(container_node: reference_node)
              figure_obj_list << figure_obj

              caption_found = false
              container_child_list.each do |child|
                case child.name
                when "img"
                  within_caption = !child.xpath(IMGPARENT_XPATH).empty?

                  if caption_found and !within_caption
                    figure_obj = UMPTG::XML::Review::Figure.new(container_node: reference_node)
                    caption_found = false
                    figure_obj_list << figure_obj
                  end
                  img_container_list = child.xpath(IMGCONTAINER_XPATH)
                  if img_container_list.empty?
                    figure_obj.img_list << UMPTG::XML::Review::Image.new(
                                container_node: child,
                                img_node: child,
                                within_caption: within_caption
                              )
                  else
                    img_container_list.each do |img_container|
                      figure_obj.img_list << UMPTG::XML::Review::Image.new(
                                  container_node: img_container,
                                  img_node: child,
                                  within_caption: within_caption
                                )
                    end
                  end
                else
                  figure_obj.caption_list << child
                  caption_found = true
                end
              end

              figure_obj_list.each do |figure_obj|
                figure_container = figure_obj.container_node
                container_normalized = figure_container.name == "figure"
                figure_obj.img_list.each do |img_obj|
                  reference_node = img_obj.img_node

                  resource_path = reference_node["src"]

                  @resource_path_list[name] << resource_path

                  img_container = img_obj.container_node

                  reference_action_list << ResourceFilter.add_image_action(
                            name: name,
                            reference_node: reference_node
                            )

                  if img_obj.within_caption
                    reference_action_list << UMPTG::XML::Pipeline::Action.new(
                             name: name,
                             reference_node: reference_node,
                             warning_message: "image: #{resource_path} is found within a figure caption."
                         )
                    next
                  end

                  if container_normalized
                    reference_action_list << UMPTG::XML::Pipeline::Action.new(
                             name: name,
                             reference_node: reference_node,
                             info_message: "image: \"#{resource_path}\" has element #{figure_container.name} as figure container."
                         )
                  else
                    reference_action_list << UMPTG::XML::Review::Actions::NormalizeFigureContainerAction.new(
                             name: name,
                             reference_node: reference_node,
                             resource_path: resource_path,
                             #xpath: xpath_base + "/" + @@DIV_XPATH,
                             action_node: figure_container,
                             warning_message: "image: \"#{resource_path}\" figure container element should be normalized."
                         )
                    container_normalized = true
                  end
                end

                if figure_obj_list.count == 1 and figure_obj.caption_list.count > 0
                  caption_list = figure_obj.caption_list

                  case
                  when figure_obj.img_list.count > 0
                    resource_path = figure_obj.img_list.first.img_node["src"]
                  when figure_obj.container_node.key?("data-fulcrum-embed-filename")
                    resource_path = figure_obj.container_node["data-fulcrum-embed-filename"]
                  else
                    resource_path = "(unknown)"
                  end

                  if caption_list.count == 1 and caption_list.first.name == "figcaption"
                    reference_action_list << UMPTG::XML::Pipeline::Action.new(
                             name: name,
                             reference_node: caption_list.first,
                             info_message: "image: #{figure_obj.img_list.count} \"#{resource_path}\" has element #{caption_list.first.name} as figure caption container."
                         )
                  else
                    reference_action_list << UMPTG::XML::Review::Actions::NormalizeFigureCaptionAction.new(
                             name: name,
                             figure_container: figure_obj.container_node,
                             #resource_path: resource_path,
                             #xpath: xpath_base.strip + "/" + @@FIGUREDIV_XPATH.strip + @@CAPTION_XPATH.strip,
                             #action_node: node,
                             cap_list: figure_obj.caption_list,
                             warning_message: "image: figure caption should be normalized."
                         )
                    figure_obj.caption_list.each do |caption_node|
                      if caption_node.key?("style")
                        # Report @style on caption blocks.
                        reference_action_list << UMPTG::XML::Review::Actions::NormalizeFigureCaptionStyleAction.new(
                                 name: name,
                                 reference_node: caption_node,
                                 resource_path: resource_path,
                                 warning_message: "image: \"#{resource_path}\" has caption element #{caption_node.name} with @style=\"#{caption_node['style']}\"."
                             )
                      end
                    end
                  end
                end
              end

              figure_obj_list.each do |figure_obj|
                if figure_obj.img_list.empty?
                  reference_action_list << UMPTG::XML::Pipeline::Action.new(
                           name: name,
                           reference_node: figure_obj.container_node,
                           error_message: "image: figure object with no image node."
                       )
                  next
                end
                figure_obj.img_list.each do |img_obj|
                  img_container = img_obj.container_node

                  unless img_obj.within_caption or img_container.name == "div"
                    reference_node = img_obj.img_node
                    resource_path = reference_node["src"]
                    reference_action_list << UMPTG::XML::Review::Actions::NormalizeImageContainerAction.new(
                             name: name,
                             reference_node: img_container,
                             #xpath: xpath_base + "/" + @@DIV_XPATH,
                             action_node: img_container,
                             warning_message: "image: container element should be normalized."
                          )
                  end
                end
              end

              if figure_obj_list.count > 1
                figure_obj_list.each do |figure_obj|
                  next if figure_obj.img_list.empty?
                  #next if figure_obj.container_node.name.downcase == "figure"
                  reference_action_list << UMPTG::XML::Review::Actions::NormalizeFigureNestAction.new(
                           name: name,
                           reference_node: figure_obj.container_node,
                           #resource_path: resource_path,
                           figure_container: figure_obj.container_node,
                           caption_location: :caption_after,
                           figure_obj: figure_obj,
                           warning_message: "image: figure container element should be normalized via nesting."
                       )
                end
              end
            end
          end
        end
      end
      return reference_action_list
    end

    def self.add_image_action(args = {})
      name = args[:name]
      reference_node = args[:reference_node]

      act = UMPTG::XML::Pipeline::Action.new(
              name: name,
              reference_node: reference_node
              )
      rpath = reference_node['src']
      if rpath.nil? or rpath.strip.empty?
        rpath = "(not specified)"
        act.add_error_msg("image: \"\" has no src path")
      else
        act.add_info_msg(   "image: \"#{rpath}\" has src path")
      end

      alt = reference_node['alt']
      act.add_info_msg(   "image: \"#{rpath}\" has alt text") unless alt.nil? or alt.empty?
      act.add_warning_msg("image: \"#{rpath}\" has no alt text") if alt.nil? or alt.empty?

      return act
    end
  end
end
