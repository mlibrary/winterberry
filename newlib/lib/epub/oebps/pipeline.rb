module UMPTG::EPUB::OEBPS
  require_relative File.join('pipeline', 'filter')

  def self.Processor(args = {})
    a = args.clone

    a[:filters] = a[:filters].nil? ? UMPTG::EPUB::OEBPS::Pipeline.FILTERS : \
                  a[:filters].merge(UMPTG::EPUB::OEBPS::Pipeline.FILTERS)

    return UMPTG::XML::Processor(a)
  end
end
