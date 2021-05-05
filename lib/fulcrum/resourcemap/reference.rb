module UMPTG::Fulcrum::ResourceMap
  class Reference < ResourceMapObject

    def initialize(args = {})
      name = args[:name]

      id = args[:id]
      id = ResourceMapObject.name_id(name) if id.nil?
      args[:id] = id

      super(args)
    end
  end
end
