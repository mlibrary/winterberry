module UMPTG::Fulcrum::Metadata::XHTML
  require_relative(File.join("pipeline", "filter"))

  def self.Processor(args = {})
    a = args.clone

    a[:filters] = a[:filters].nil? ? UMPTG::Fulcrum::Metadata::XHTML::Pipeline.FILTERS : \
                  a[:filters].merge(UMPTG::Fulcrum::Metadata::XHTML::Pipeline.FILTERS)

    return UMPTG::XHTML::Processor(a)
  end
end
