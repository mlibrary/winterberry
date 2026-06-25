module UMPTG::XHTML::Pipeline
  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }

  FFILTERS = {
        xhtml_acronym: UMPTG::XHTML::Pipeline::Filter::AcronymFilter,
        xhtml_header_class: UMPTG::XHTML::Pipeline::Filter::HeaderClassFilter,
      }

  def self.FILTERS
    return FFILTERS
  end
end
