module UMPTG::EPUB::NCX
  require_relative File.join('pipeline', 'filter')
  require_relative File.join('pipeline', 'processor')

  def self.Processor(args = {})
    return Pipeline::Processor.new(args)
  end
end
