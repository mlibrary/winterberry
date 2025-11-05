module UMPTG::CSS
  require_relative(File.join("pipeline", "actions"))
  require_relative(File.join("pipeline", "filter"))
  require_relative(File.join("pipeline", "filter", "fontfacefilter"))
  require_relative(File.join("pipeline", "filter", "timesfontfilter"))
  require_relative(File.join("pipeline", "processor"))

  FILTERS = {
            css_font_face: UMPTG::CSS::Pipeline::FontFaceFilter,
            css_times_font: UMPTG::CSS::Pipeline::TimesFontFilter
      }

  def self.Processor(args = {})
    a = args.clone
    a[:filters] = a[:filters].nil? ? UMPTG::CSS.FILTERS : \
                  a[:filters].merge(UMPTG::CSS.FILTERS)
    return UMPTG::CSS::Pipeline::Processor.new(a)
  end

  def self.fulcrum_default
    return UMPTG::CSS.fulcrum_css("fulcrum_default.css")
  end

  def self.fulcrum_enhanced
    return UMPTG::CSS.fulcrum_css("fulcrum_enhanced.css")
  end

  def self.FILTERS
    return FILTERS
  end

  private

  def self.fulcrum_css(bname)
    css_file = File.join(File.dirname(__FILE__), "css", bname)
    return File.read(css_file)
  end
end
