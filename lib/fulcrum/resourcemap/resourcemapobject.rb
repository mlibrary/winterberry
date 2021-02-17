module UMPTG::Fulcrum::ResourceMap
  class ResourceMapObject
    attr_reader :id, :name

    def initialize(args = {})
      @id = args[:id]
      @name = args[:name]
    end

    def to_s
      return "id=#{@id},name=#{@name}"
    end

    def self.name_id(name)
      return name.gsub(/[ \.\/\\]/, '_') unless name.nil?
    end
  end
end
