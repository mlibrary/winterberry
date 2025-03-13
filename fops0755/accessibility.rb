module UMPTG
  require_relative(File.join("accessibility", "filters"))
  require_relative(File.join("accessibility", "processor"))

  class << self
    def Accessibility(args = {})
      return Accessibility::Processor.new(args)
    end
  end
end
