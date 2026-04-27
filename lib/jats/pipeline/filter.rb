module UMPTG::JATS::Pipeline
  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }

  FILTERS = {
        jats_article_type: UMPTG::JATS::Pipeline::Filter::ArticleTypeFilter,
      }

  def self.FILTERS
    return FILTERS
  end
end
