module UMPTG::Resources

  require 'nokogiri'

  class ReferenceSelector
    def references(xml_doc)
      return []
    end

    def reference?(node)
      return node.comment? ? :marker : :element
    end
  end
end
