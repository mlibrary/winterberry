class ResourceMapReference < ResourceMapBase

  def initialize(args = {})
    name = args[:name]
    args[:name] = name

    id = args[:reference_id]
    id = ResourceMapBase.name_id(name) if id.nil?
    args[:id] = id

    super(args)
  end
end
