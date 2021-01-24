module UMPTG
  class Object
    def initialize(args = {})
      @properties = args.clone
    end

    def property(key, val = nil)
      if val.nil?
        raise "#{__method__}: invalid key #{key}" unless @properties.key?(key)
        return @properties[key]
      else
        @properties[key] = val
      end
    end

    def to_s
      return @properties.to_s
    end
  end
end
