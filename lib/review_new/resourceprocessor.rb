module UMPTG::Review

  # Class processes each resource reference found within XML content.
  class ResourceProcessor < EntryProcessor

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
    parent::*[local-name()!='figcaption']
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

    attr_reader :resource_path_list

    # Processing parameters:
    #   :selector               Class for selecting resource references
    #   :logger                 Log messages
    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: RESOURCE_REFERENCE_XPATH
            )
      super(args)

      reset()
      @resource_path_list = {}
    end

    def action_list(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      @resource_path_list[name] = []

      reference_action_list = []
      unless @selector.nil? or xml_doc.nil?

        reference_list = @selector.references(xml_doc)

        reference_list.each do |reference_node|
          case reference_node.name
          when "img"
            resource_path = reference_node["src"]
            reference_action_list << ImageAction.new(
                    name: name,
                    reference_node: reference_node,
                    resource_path: resource_path
                )
            @resource_path_list[name] << resource_path

            reference_action_list << Action.new(
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
                reference_action_list << Action.new(
                         name: name,
                         reference_node: reference_node,
                         warning_message: "image: has element #{reference_node.name} as figure container and @data-fulcrum-embed-filename is empty."
                     )
              else
                @resource_path_list[name] << resource_path
                reference_action_list << Action.new(
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
                  reference_action_list << Action.new(
                           name: name,
                           reference_node: reference_node,
                           warning_message: "image: has element #{reference_node.name} as figure container and is empty."
                       )
                else
                  figure_obj = Figure.new(container_node: reference_node)
                  figure_obj_list << figure_obj

                  caption_found = false
                  container_child_list.each do |child|
                    case child.name
                    when "img"
                      if caption_found
                        figure_obj = Figure.new(container_node: reference_node)
                        figure_obj_list << figure_obj
                        caption_found = false
                      end
                      img_container_list = child.xpath(IMGCONTAINER_XPATH)
                      if img_container_list.empty?
                        figure_obj.img_list << Image.new(
                                    container_node: child,
                                    img_node: child
                                  )
                      else
                        img_container_list.each do |img_container|
                          figure_obj.img_list << Image.new(
                                      container_node: img_container,
                                      img_node: child
                                    )

                          unless img_container.name == "div"
                            reference_action_list << NormalizeImageContainerAction.new(
                                     name: name,
                                     reference_node: img_container,
                                     #xpath: xpath_base + "/" + @@DIV_XPATH,
                                     action_node: img_container,
                                     warning_message: "image: container element should be normalized."
                                  )
                          end
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

                      reference_action_list << ImageAction.new(
                              name: name,
                              reference_node: reference_node,
                              resource_path: resource_path
                          )

                      if figure_container.name == "figure"
                        reference_action_list << Action.new(
                                 name: name,
                                 reference_node: reference_node,
                                 info_message: "image: \"#{resource_path}\" has element #{figure_container.name} as figure container."
                             )
                      elsif !container_normalized
                        reference_action_list << NormalizeFigureContainerAction.new(
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
                      if caption_list.count == 1 and caption_list.first.name == "figcaption"
                        case
                        when figure_obj.img_list.count > 0
                          resource_path = figure_obj.img_list.first.img_node["src"]
                        when figure_obj.container_node.key?("data-fulcrum-embed-filename")
                          resource_path = figure_obj.container_node["data-fulcrum-embed-filename"]
                        else
                          resource_path = "(unknown)"
                        end
                        reference_action_list << Action.new(
                                 name: name,
                                 reference_node: caption_list.first,
                                 info_message: "image: #{figure_obj.img_list.count} \"#{resource_path}\" has element #{caption_list.first.name} as figure caption container."
                             )
                      else
                        reference_action_list << NormalizeFigureCaptionAction.new(
                                 name: name,
                                 figure_container: figure_obj.container_node,
                                 #resource_path: resource_path,
                                 #xpath: xpath_base.strip + "/" + @@FIGUREDIV_XPATH.strip + @@CAPTION_XPATH.strip,
                                 #action_node: node,
                                 cap_list: figure_obj.caption_list,
                                 warning_message: "image: figure caption should be normalized."
                             )
                      end
                    end
                  end

                  if figure_obj_list.count > 1
                    figure_obj_list.each do |figure_obj|
                      reference_action_list << NormalizeFigureNestAction.new(
                               name: name,
                               #reference_node: reference_node,
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
        end
      end

      # Return the list of Actions which contains the status
      # for each.
      return reference_action_list
    end

    def reset()
      super()
      @resource_path_list = {}
    end

    private

    def marker_reference_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]
      figure_container = args[:figure_container]

      rnode = figure_container.nil? ? reference_node : figure_container

      action_list = []
      if rnode.key?("data-fulcrum-embed-filename") and !rnode["data-fulcrum-embed-filename"].empty?
        resource_path = rnode["data-fulcrum-embed-filename"]
        @resource_path_list[name] << resource_path

        action_list << Action.new(
                 name: name,
                 reference_node: node
             )
        if rnode.name == "figure"
          action_list.last.add_info_msg("marker: \"#{resource_path}\" has markup #{rnode.to_xhtml}.")
        else
          action_list.last.add_warning_msg("marker: \"#{resource_path}\" has markup #{rnode.to_xhtml}.")
        end
        ResourceProcessor.add_filename_spaces_msg(action_list.last, resource_path, false)
      else
        # Return the nodes that reference resources.
        # For marker callouts, this should be within
        # a XML comment, but not always the case.
        node_list = rnode.xpath(".//comment()")
        node_list = [ rnode ] if node_list.nil? or node_list.empty?
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

          @resource_path_list[name] << resource_path

          action_list << Action.new(
                   name: name,
                   reference_node: node,
                   warning_message: "marker: \"#{resource_path}\" found and has #{node.name} as marker element. Recommended markup is <figure data-fulcrum-embed-filename=\"#{resource_path}\"]."
               )
          ResourceProcessor.add_filename_spaces_msg(action_list.last, resource_path, false)

          xpath = "//*[(@class='rb' or @class='rbi') and contains(normalize-space(.),'#{resource_path}')]|//comment()[starts-with(translate(normalize-space(.),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'insert ') and contains(normalize-space(.),'#{resource_path}')]"
          #node_list = rnode.document.xpath(xpath)
          #puts "resource:#{resource_path},#{rnode},#{node_list.count}"
          action_list << NormalizeMarkerAction.new(
                     name: name,
                     reference_node: rnode,
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
