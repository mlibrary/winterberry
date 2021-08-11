module UMPTG::Review

  class NormalizeAction < Action
    @@NORMALIZED = "Normalized"

    def process(args = {})
      super(args)
      @status = NormalizeAction.NORMALIZED
    end

    def self.NORMALIZED
      @@NORMALIZED
    end
  end
end
