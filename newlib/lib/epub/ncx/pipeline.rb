module UMPTG::EPUB::NCX
  require_relative File.join('pipeline', 'filter')

  def self.Processor(args = {})
    a = args.clone

    a[:filters] = a[:filters].nil? ? UMPTG::EPUB::NCX::Pipeline.FILTERS : \
                  a[:filters].merge(UMPTG::EPUB::NCX::Pipeline.FILTERS)

    return UMPTG::XML::Processor(a)
  end
end
