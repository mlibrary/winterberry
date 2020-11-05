module UMPTG::Manifest::ValidationResult
  class VMNode < VNode
    def initialize(args = {})
      super(args)
    end

    def to_s
      return "monograph[#{@attrs.to_h['id']}]"
    end
  end
end
