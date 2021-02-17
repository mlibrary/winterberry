module UMPTG::Fulcrum::ResourceMap
  class Reference < ResourceMapObject

    def initialize(args = {})
      super(args)

      name = args[:name]
      args[:name] = name

      id = args[:reference_id]
      id = ResourceMapObject.name_id(name) if id.nil?
      args[:id] = id

      super(args)
    end
  end
end
