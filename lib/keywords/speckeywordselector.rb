module UMPTG::Keywords

  require 'nokogiri'

  class SpecKeywordSelector


  # XPath expression for retrieving keywords
@@SELECTION_XPATH = <<-SXPATH
//*[
local-name()='span' and (@class='tetr' or @class='tetr-i')
]
SXPATH

    def references(xml_doc)
      return xml_doc.xpath(@@SELECTION_XPATH)
    end

    def reference?(node)
      # Select //*[local-name()='span' and (@class='tetr' or @class='tetr-i')]
      return false unless name == 'span'

      pclass = attrs.to_h['class']
      return false if pclass.nil? or pclass.empty?

      pclass_list = pclass.split(' ')
      return true if pclass.include?('tetr') or pclass.include?('tetr-i')
      return false
    end
  end
end
