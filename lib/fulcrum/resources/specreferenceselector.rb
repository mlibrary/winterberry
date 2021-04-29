module UMPTG::Fulcrum::Resources

  require 'nokogiri'

  # Class selects XML elements that contain resources
  # to embed|link
  class SpecReferenceSelector < ReferenceSelector

  @@SELECTION_XPATH = <<-SXPATH
  //*[
  (local-name()='p' and @class='fig')
  or (local-name()='figure' and count(*[local-name()='p' and @class='fig'])=0)
  or @class='rb'
  or @class='rbi'
  ]
  SXPATH

    # Method determines whether a reference is either a
    # resource to be embed|link, or an additional resource
    # to be inserted
    def reference_type(node)
      attr = node.attribute("class")
      unless attr.nil?
        attr = attr.text.downcase
        return :marker if attr == "rb" or attr == "rbi"
      end
      return :element
    end
  end
end
