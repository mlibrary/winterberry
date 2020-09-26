module UMPTG::ResourceMap

  class Resource < UMPTG::ResourceMap::ResourceMapObject
    attr_accessor :properties

    def initialize(args = {})
      name = args[:name]
      args[:name] = name
      args[:id] = args.has_key?(:resource_id) ? args[:resource_id] : \
              UMPTG::ResourceMap::ResourceMapObject.name_id(name)
      super(args)

      @properties = args[:resource_properties]
    end
  end
end
