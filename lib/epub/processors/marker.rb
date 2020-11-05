module UMPTG::EPUB::Processors
  class Marker < Object

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
