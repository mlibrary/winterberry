module UMPTG
  class CSS
    def self.fulcrum_default
      return UMPTG::CSS.fulcrum_css("fulcrum_default.css")
    end

    def self.fulcrum_enhanced
      return UMPTG::CSS.fulcrum_css("fulcrum_enhanced.css")
    end

    private

    def self.fulcrum_css(bname)
      css_file = File.join(File.dirname(__FILE__), "css", bname)
      return File.read(css_file)
    end
  end
end