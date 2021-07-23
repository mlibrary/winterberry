module UMPTG::Review

  require 'nokogiri'

  # Class selects XML elements that contain resources
  # to embed|link
  class ResourceReferenceSelector < ElementSelector

    @@SELECTION_XPATH = <<-SXPATH
    //*[
    local-name()='img'
    or @class='rb'
    or @class='rbi'
    or comment()[starts-with(translate(normalize-space(.),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'insert ')]
    ]
    SXPATH

    # Method determines whether a reference is either a
    # resource to be embed|link, or an additional resource
    # to be inserted
    def reference_type(node)
      if node.comment? or (node.key?("class") and (node['class'].downcase == 'rb' or node['class'].downcase = 'rbi'))
        return :marker
      end
      return :element
    end
  end
end
