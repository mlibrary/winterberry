module UMPTG::XML::Pipeline

  class Filter < UMPTG::Pipeline::Filter

    attr_reader :xpath

    def initialize(name:, xpath:, options: nil)
      super(name: name, options: options)
      @xpath = xpath
    end

    def select(xml_doc, options: {})
      return xml_doc.xpath(@xpath)
    end
  end

  FILTERS = {
        xml_default: UMPTG::XML::Pipeline::Filter
      }

  def self.DefaultFilter(args = {})
    return FILTERS[:xml_default].new(args)
  end

  def self.FILTERS
    return FILTERS
  end

end
