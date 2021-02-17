module UMPTG::Fulcrum::ResourceMap

  class Resource < ResourceMapObject
    attr_accessor :properties

    def initialize(args = {})
      name = args[:name]
      args[:name] = name
      args[:id] = args.has_key?(:resource_id) ? args[:resource_id] : \
              ResourceMapObject.name_id(name)
      super(args)

      @properties = args[:resource_properties]
    end
  end
end
