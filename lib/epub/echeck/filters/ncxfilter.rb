module UMPTG::EPUB::ECheck::Filter

  class NCXFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-PCKXPATH
    //*[
    local-name() = 'navPoint' and @id
    ]
    PCKXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :ncx
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      reference_node = args[:reference_node]

      actions = []

      case reference_node.name
      when "navPoint"
        id = reference_node["id"]
        id = id.nil? ? "" : id.strip
        if id[0].match?(/[[:digit:]]/)
          new_id = "nav" + id
          actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                    name: name,
                    reference_node: reference_node,
                    attribute_name: "id",
                    attribute_value: new_id,
                    warning_message: "#{name}, invalid @id value #{id}"
                  )
        else
          actions << UMPTG::XML::Pipeline::Action.new(
                          name: name,
                          reference_node: reference_node,
                          info_message: "#{name}, #{reference_node.name}"
                      )
        end
      end

      return actions
    end
  end
end
