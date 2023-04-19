module UMPTG::Fulcrum::ResourceMap
  class ResourceMapObject < UMPTG::Object
    attr_reader :id, :name

    def initialize(args = {})
      super(args)

      @id = @properties[:id]
      @name = @properties[:name]
    end

    def to_s
      return "id=#{@id},name=#{@name}"
    end

    def self.name_id(name)
      return name.gsub(/[ \.\/\\]/, '_') unless name.nil?
      return ""
    end
  end
end
