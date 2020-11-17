module UMPTG::EPUB::Processors

  # Class represents a resource encountered
  # while processing an EPUB and defined by
  # marker markup.
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
