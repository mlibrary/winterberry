module UMPTG::FOPS1065::XHTML::Pipeline
  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }

  FILTERS = {
        xhtml_footnote: UMPTG::FOPS1065::XHTML::Pipeline::Filter::FootnoteFilter,
        xhtml_img_width: UMPTG::FOPS1065::XHTML::Pipeline::Filter::ImgWidthFilter,
      }

  def self.FILTERS
    return FILTERS
  end
end
