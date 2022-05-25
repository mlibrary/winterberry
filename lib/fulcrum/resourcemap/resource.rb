module UMPTG::Fulcrum::ResourceMap

  class Resource < ResourceMapObject
    attr_accessor :resource_properties

    def initialize(args = {})
      name = args[:name]
      args[:name] = name
      args[:id] = args.has_key?(:resource_id) ? args[:resource_id] : \
              ResourceMapObject.name_id(name)

      super(args)

      @resource_properties = args[:resource_properties]
    end

    def to_s
      return super() + ",properties=#{@resource_properties}"
    end
  end
end
