module UMPTG::Fulcrum::Manifest::ValidationResult
  class VRNode < VNode
    def initialize(args = {})
      super(args)
    end

    def resource_name
      return @attrs.to_h['label']
    end

    def to_s
      monograph = @parent
      return "#{monograph.to_s}/#{@name}[#{@attrs.to_h['label']}]"
    end
  end
end
