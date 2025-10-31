module UMPTG::Fulcrum::Resources::XHTML
  require_relative(File.join("pipeline", "filter"))

  def self.Processor(args = {})
    a = args.clone

    a[:filters] = a[:filters].nil? ? UMPTG::Fulcrum::Resources::XHTML::Pipeline.FILTERS : \
                  a[:filters].merge(UMPTG::Fulcrum::Resources::XHTML::Pipeline.FILTERS)

    return UMPTG::XHTML::Processor(a)
  end
end
