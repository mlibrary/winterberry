module UMPTG::XHTML
  require_relative(File.join("pipeline", "actions"))
  require_relative(File.join("pipeline", "filter"))

  def self.Processor(args = {})
    a = args.clone

    a[:filters] = a[:filters].nil? ? UMPTG::XHTML::Pipeline.FILTERS : \
                  a[:filters].merge(UMPTG::XHTML::Pipeline.FILTERS)

    return UMPTG::XML::Processor(a)
  end
end
