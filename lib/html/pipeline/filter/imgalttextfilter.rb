module UMPTG::HTML::Pipeline::Filter

  class ImgAltTextFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='img'
    ]
    SXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :html_img_alttext
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <img> element

      action_list = []

      if reference_node.name == 'img'
        role = (reference_node["role"] || "").strip.downcase
        unless role == "presentation"
          alt = (reference_node["alt"] || "").strip
          if alt.empty?
              action_list << UMPTG::XML::Pipeline::Action.new(
                       name: name,
                       reference_node: reference_node,
                       warning_message: \
                         "#{name}, #{reference_node.name} no alt text src=\"#{reference_node['src']}\" role=\"#{reference_node['role']}\""
                   )
=begin
              action_list << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                       name: name,
                       reference_node: reference_node,
                       attribute_name: "role",
                       attribute_value: "presentation",
                       warning_message: \
                         "#{name}, #{reference_node.name} no alt text src=\"#{reference_node['src']}\" role=\"#{reference_node['role']}\""
                   )
=end
          else
            action_list << UMPTG::XML::Pipeline::Action.new(
                     name: name,
                     reference_node: reference_node,
                     info_message: \
                       "#{name}, found #{reference_node}"
                 )
          end
        end
      end
      return action_list
    end
  end
end
