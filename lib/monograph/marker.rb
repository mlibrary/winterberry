module UMPTG::Monograph
  class Marker < MonographObject

    def initialize(args = {})
      super(args)
      @resource_name = args[:resource_name]
    end

    def map
      row = super()
      row['resource_name'] = @resource_name
      return row
    end
  end
end
