module UMPTG::XHTML::Pipeline
  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }

  FFILTERS = {
        xhtml_fops1034: UMPTG::XHTML::Pipeline::Filter::FOPS1034Filter,
      }

  def self.FILTERS
    return FFILTERS
  end
end
