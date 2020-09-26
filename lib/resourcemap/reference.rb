module UMPTG::ResourceMap
  class Reference < UMPTG::ResourceMap::ResourceMapObject

    def initialize(args = {})
      name = args[:name]
      args[:name] = name

      id = args[:reference_id]
      id = UMPTG::ResourceMap::ResourceMapObject.name_id(name) if id.nil?
      args[:id] = id

      super(args)
    end
  end
end
