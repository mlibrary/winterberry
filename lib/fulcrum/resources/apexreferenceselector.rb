module UMPTG::Fulcrum::Resources

  require 'nokogiri'

  # Class selects XML elements that contain resources
  # to embed|link
  class ApexReferenceSelector < ReferenceSelector

  @@SELECTION_XPATH = <<-SXPATH
  //*[
  (local-name()='figure' and count(*[local-name()='p' and @class='fig'])=0)
  or (local-name()='div' and @class='fig')
  or (local-name()='p' and starts-with(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'),'<insert ') and substring(text(),string-length(text()),1)='>')
  ]
  SXPATH

    # Method determines whether a reference is either a
    # resource to be embed|link, or an additional resource
    # to be inserted
    def reference_type(node)
      if node.name == 'p'
        content = node.text
        unless content.nil? or content.empty?
          return :marker if content.downcase.match?(/\<insert[ ]+[^\>]+\>/)
        end
      end
      return :element
    end
  end
end
