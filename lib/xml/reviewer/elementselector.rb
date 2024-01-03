module UMPTG::XML::Reviewer

  class ElementSelector < UMPTG::XML::Pipeline::Filter::ElementSelector
    def reference_type(node)
      return :marker if node.comment? or (node.name == 'p' and (node['class'] == 'rb' or node['class'] == 'rbi'))
      return :element
    end
  end
end
