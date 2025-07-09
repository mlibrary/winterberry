module UMPTG::EPUB
  require_relative(File.join("echeck", "filters"))
  require_relative(File.join("echeck", "processor"))

  class << self
    def ECheck(args = {})
      return ECheck::Processor.new(args)
    end
  end
end
