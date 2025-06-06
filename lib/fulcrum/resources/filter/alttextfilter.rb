module UMPTG::Fulcrum::Resources::Filter

  class AltTextFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='img'
    ]
    SXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :alt_text
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <img> element

      raise "unknown element #{reference_node.name}" unless reference_node.name == 'img'

      action_list = []

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
        end
      end

      return action_list
    end
  end
end
