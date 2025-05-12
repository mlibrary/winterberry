module UMPTG::XHTML
  require_relative(File.join("pipeline", "filter"))
  require_relative(File.join("pipeline", "processor"))

  class << self
    def Processor(args = {})
      return Pipeline::Processor.new(args)
    end
  end
end
