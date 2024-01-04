module UMPTG::XML::Review

  class ElementSelector < UMPTG::XML::Pipeline::ElementSelector
    def reference_type(node)
      return :marker if node.comment? or (node.name == 'p' and (node['class'] == 'rb' or node['class'] == 'rbi'))
      return :element
    end
  end
end
