module UMPTG::EPUB

  require_relative File.join('pipeline', 'processor')

  def self.Processor(args = {})
    return Pipeline::Processor.new(args)
  end
end
