module UMPTG::Fulcrum::Manifest::ValidationResult
  class VNodeFactory
    def self.construct(args = {})
      name = args[:name]

      n = nil
      case
      when name == 'monograph'
        n  = VMNode.new(args)
      when CollectionSchema.resource?(name)
        n  = VRNode.new(args)
      else
        # Property
        n = VNode.new(args)
      end

      return n
    end
  end
end
