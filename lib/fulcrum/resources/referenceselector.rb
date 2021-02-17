module UMPTG::Fulcrum::Resources

  require 'nokogiri'

  # Class is base for resource reference selection.
  class ReferenceSelector < UMPTG::Object

    def references(xml_doc)
      return []
    end

    def reference_type(node)
      return node.comment? ? :marker : :element
    end
  end
end
