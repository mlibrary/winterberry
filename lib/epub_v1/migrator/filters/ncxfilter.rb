module UMPTG::EPUB::Migrator::Filter

  class NCXFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-PCKXPATH
    //*[
    local-name() = 'navPoint' or local-name()='pageTarget' or local-name()='content'
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
      when "content"
        src = reference_node["src"]
        new_src = UMPTG::EPUB::Migrator.fix_ext(src)
        unless src == new_src
          actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                    name: name,
                    reference_node: reference_node,
                    attribute_name: "src",
                    attribute_value: new_src,
                    warning_message: "#{name}, found #{reference_node.name}/@src=\"#{src}\""
                  )
        end
      else
        id = reference_node["id"]
        id = id.nil? ? "" : id.strip
        if id.match?(/^[0-9]/)
          new_id = reference_node.name == "navPoint" ? "nav" + id : "page" + id
          actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                    name: name,
                    reference_node: reference_node,
                    attribute_name: "id",
                    attribute_value: new_id,
                    warning_message: "#{name}, invalid id value #{id}"
                  )
        end
      end

      return actions
    end
  end
end
