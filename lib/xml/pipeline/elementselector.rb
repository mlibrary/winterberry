module UMPTG::XML::Pipeline

  require 'nokogiri'

  # Class is base for resource reference selection.
  class ElementSelector < UMPTG::Object
    attr_reader :xpath

    def initialize(args = {})
      super(args)
      @xpath = @properties[:selection_xpath]
      raise "Error: no xpath expression specified." if @xpath.nil?
    end

    def references(xml_doc)
      return xml_doc.xpath(@xpath)
    end

    def reference_type(node)
      return :element
    end
  end
end
