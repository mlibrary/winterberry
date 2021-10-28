module UMPTG::Review

  class NormalizeAction < Action
    attr_reader :resource_path, :xpath

    @@NORMALIZED = "Normalized"

    def initialize(args = {})
      super(args)

      @normalize = true

      @resource_path = @properties[:resource_path]
      @xpath = @properties[:xpath]
    end

    def process(args = {})
      super(args)

      @status = NormalizeAction.NORMALIZED
    end

    def self.NORMALIZED
      @@NORMALIZED
    end
  end
end
