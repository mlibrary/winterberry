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

    def action_list(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      @resource_path_list[name] = []

      reference_action_list = []
      unless @selector.nil? or xml_doc.nil?

        reference_list = @selector.references(xml_doc)

        figure_list = []
        reference_list.each do |reference_node|
          figure_container_list = reference_node.xpath(@@FIGUREDIV_XPATH)
          if figure_container_list.empty?
            figure_container = nil
            img_container = nil
          else
            figure_container = figure_container_list.first
            img_container_list = figure_container.xpath(sprintf(@@IMGCONTAINER_XPATH, reference_node.name, reference_node["src"]))
            img_container = img_container_list.empty? ? reference_node : img_container_list.first
          end

          img_obj = {
                reference_node: reference_node,
                container_node: img_container
                }
          if figure_list.empty? or figure_container.nil? or figure_list.last[:container] != figure_container
            figure_obj = {
                  container: figure_container_list.empty? ? nil : figure_container,
                  img_list: [ img_obj ],
                  container_normalized: false
                  }
            figure_list << figure_obj
          else
            figure_list.last[:img_list] << img_obj
          end
        end

        figure_list.each do |figure_obj|
          figure_container = figure_obj[:container]
          container_normalized = figure_obj[:container_normalized]

          figure_obj[:img_list].each do |img_obj|
            reference_node = img_obj[:reference_node]

            if @selector.reference_type(reference_node) == :marker
              reference_action_list += marker_reference_actions(
                        name: name,
                        reference_node: reference_node,
                        figure_container: figure_container
                    )
              next
            end

            resource_path = reference_node["src"]

            @resource_path_list[name] << resource_path

            img_container = img_obj[:container]

            reference_action_list << ImageAction.new(
                    name: name,
                    reference_node: reference_node,
                    resource_path: resource_path
                )

            if figure_container.nil?
              reference_action_list << Action.new(
                       name: name,
                       reference_node: reference_node,
                       warning_message: "image: \"#{resource_path}\" unable to determine figure container element."
                   )
            elsif figure_container.name == "figure"
              reference_action_list << Action.new(
                       name: name,
                       reference_node: reference_node,
                       info_message: "image: \"#{resource_path}\" has element #{figure_container.name} as figure container."
                   )
            else !container_normalized
              reference_action_list << NormalizeFigureContainerAction.new(
                       name: name,
                       reference_node: reference_node,
                       resource_path: resource_path,
                       #xpath: xpath_base + "/" + @@DIV_XPATH,
                       action_node: figure_container,
                       warning_message: "image: \"#{resource_path}\" figure container element should be normalized."
                   )
              figure_obj[:container_normalized] = true
            end
          end

          unless figure_container.nil?
            container_child_list = figure_container.xpath(@@IMGCAPTION_XPATH)
            if container_child_list.empty?
              # Probably a figure that contains a marker.
              # Give warning, but shouldn't be an issue.
              reference_action_list << Action.new(
                       name: name,
                       reference_node: figure_container,
                       warning_message: "image: has element #{figure_container.name} as figure container and is empty."
                   )
            else
              caption_location = container_child_list.first.name == "img" ? :caption_after : :caption_before
              sfig_obj = {
                     img_list:  [],
                     cap_list: []
                  }
              sfig_list = [sfig_obj]
              state = :img
              cnode = container_child_list.first.name
              container_child_list.each do |node|
                if node.name == "img"
                  img_container_list = figure_container.xpath(sprintf(@@IMGCONTAINER_XPATH, node.name, node["src"]))
                  next if img_container_list.empty?
                  img_container = img_container_list.first
                else
                  img_container = nil
                end

                case state
                when :img
                  if node.name == "img"
                    sfig_obj[:img_list] << img_container
                  else
                    unless node.name == "figcaption"
                      cap_parent_list = node.xpath("./ancestor::*[local-name()='figcaption']")
                      if cap_parent_list.empty?
                        sfig_obj[:cap_list] << node
                        state = :cap
                      end
                    end
                  end
                when :cap
                  if node.name == "img"
                    sfig_obj = {
                           img_list:  [img_container],
                           cap_list: []
                        }
                    sfig_list << sfig_obj
                    state = :img
                  else
                    unless node.name == "figcaption"
                      cap_parent_list = node.xpath("./ancestor::*[local-name()='figcaption']")
                      if cap_parent_list.empty?
                        sfig_obj[:cap_list] << node
                      end
                    end
                  end
                end
              end

              sfig_list2 = sfig_list.select {|sfig_obj| sfig_obj[:cap_list].count > 0 }

              if sfig_list2.count == 1
                sfig_list2.each do |sfig_obj|
                  if sfig_obj[:cap_list].count > 0
                    reference_action_list << NormalizeFigureCaptionAction.new(
                             name: name,
                             figure_container: figure_container,
                             #resource_path: resource_path,
                             #xpath: xpath_base.strip + "/" + @@FIGUREDIV_XPATH.strip + @@CAPTION_XPATH.strip,
                             #action_node: node,
                             cap_list: sfig_obj[:cap_list],
                             warning_message: "image: figure caption should be normalized."
                         )
                  end
                end
              else
                sfig_list2.each do |sfig_obj|
                  reference_action_list << NormalizeFigureNestAction.new(
                           name: name,
                           #reference_node: reference_node,
                           #resource_path: resource_path,
                           figure_container: figure_container,
                           caption_location: caption_location,
                           sfig_obj: sfig_obj,
                           warning_message: "image: figure container element should be normalized via nesting."
                       )
                end
              end

              sfig_list2.each do |sfig_obj|
                sfig_obj[:img_list].each do |node|
                  next if node.name == "div"
                  reference_action_list << NormalizeImageContainerAction.new(
                           name: name,
                           reference_node: node,
                           #xpath: xpath_base + "/" + @@DIV_XPATH,
                           action_node: node,
                           warning_message: "image: container element should be normalized."
                        )
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

=begin
  Current code starts here
=end

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
    ((local-name()='p' or local-name()='div') and translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figurewrap')
    ][1]
    DXPATH

    @@FIGUREDIV_XPATH = <<-FDXPATH
    ./ancestor::*[
    local-name()='figure'
    or ((local-name()='p' or local-name()='div') and translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figurewrap')
    ][1]
    FDXPATH

    @@IMGCAPTION_XPATH = <<-ICXPATH
    .//*[
    local-name()='img'
    or local-name()='figcaption'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figh'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='fign'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='image_caption'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figattrib'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figpara'
    or starts-with(translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'figcap')
    or starts-with(translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'figcaption')
    ]
    ICXPATH

    @@IMGCONTAINER_XPATH = <<-ICOXPATH
    ./descendant::*[
    .//*[
    local-name()='%s' and @src='%s'
    ]//ancestor::*[
    local-name()='p' or local-name()='div'
    ]
    ]
    ICOXPATH

    @@CAPBASE_XPATH = <<-CBXPATH
    local-name()='figcaption'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='figh'
    or translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='image_caption'
    or starts-with(translate(@class,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'figcap')
    CBXPATH
    @@CAPAFTER_XPATH = @@IMGCONTAINER_XPATH + "/following-sibling::*[" + @@CAPBASE_XPATH + "][1]"
    @@CAPBEFORE_XPATH = @@IMGCONTAINER_XPATH + "/preceding-sibling::*[" + @@CAPBASE_XPATH + "][1]"

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

      resource_path = reference_node.key?('src') ? reference_node['src'] : ""

      action_list = [
            ImageAction.new(
                 name: name,
                 reference_node: reference_node,
                 resource_path: resource_path
             )
           ]

      unless resource_path.strip.empty?
        @resource_path_list[name] << resource_path

        xpath_base = "//*[local-name()='img' and @src='#{resource_path}']"
        ResourceProcessor.add_filename_spaces_msg(action_list.last, resource_path)

        # Normalize figure container, if possible.
        container_list = reference_node.xpath(@@FIGUREDIV_XPATH)
        if container_list.empty?
          action_list << Action.new(
                   name: name,
                   reference_node: reference_node,
                   warning_message: "image: \"#{resource_path}\" unable to determine container element."
               )
        else
          container_node = container_list.first

          if container_node.name == "figure"
            action_list << Action.new(
                     name: name,
                     reference_node: reference_node,
                     info_message: "image: \"#{resource_path}\" has #{container_node.name} as container element."
                 )
          elsif !@processed_container.key?(container_node)
            action_list << NormalizeFigureAction.new(
                     name: name,
                     reference_node: reference_node,
                     resource_path: resource_path,
                     xpath: xpath_base + "/" + @@DIV_XPATH,
                     action_node: container_node
                 )
            @processed_container[container_node] = true
          end

          img_container_list = container_node.xpath(sprintf(@@IMGCONTAINER_XPATH, reference_node.name, resource_path))
          action_list.last.add_info_msg("img_container_list:#{img_container_list.count}")
          img_container_list.each do |node|
            #if node.name == "div"
            if true or node.name == "div"
              action_list << Action.new(
                       name: name,
                       reference_node: reference_node,
                       warning_message: "image: \"#{resource_path}\" has #{node.name} as container element for image element."
                   )
            else
              action_list << NormalizeImageContainerAction.new(
                       name: name,
                       reference_node: reference_node,
                       resource_path: resource_path,
                       xpath: xpath_base + "/" + @@DIV_XPATH,
                       action_node: node
                   )
            end
          end

          container_child_list = container_node.xpath(@@IMGCAPTION_XPATH)
          if container_child_list.first.name == "img"
            caption_location = :caption_after
            caption_list = container_node.xpath(sprintf(@@CAPAFTER_XPATH, reference_node.name, resource_path))
          else
            caption_location = :caption_before
            caption_list = container_node.xpath(sprintf(@@CAPBEFORE_XPATH, reference_node.name, resource_path))
          end

          if caption_list.empty?
            # No caption found.
            action_list << Action.new(
                     name: name,
                     reference_node: reference_node,
                     warning_message: "image: \"#{resource_path}\" unable to determine caption element."
                 )
          else
            caption_node = caption_list.first
            if caption_node.name == "figcaption"
              action_list << Action.new(
                       name: name,
                       reference_node: reference_node,
                       info_message: "image: \"#{resource_path}\" has #{caption_node.name} as caption element. Recommended element is figcaption."
                   )
            else
              action_list << NormalizeFigureCaptionAction.new(
                       name: name,
                       reference_node: reference_node,
                       resource_path: resource_path,
                       xpath: xpath_base.strip + "/" + @@FIGUREDIV_XPATH.strip + @@CAPTION_XPATH.strip,
                       action_node: caption_node
                   )
            end
          end
        end
      end

      return action_list
    end

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
