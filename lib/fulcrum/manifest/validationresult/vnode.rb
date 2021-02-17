module UMPTG::Fulcrum::Manifest::ValidationResult
  class VNode < UMPTG::Object
    attr_accessor :name, :attrs, :parent, :line_num

    def initialize(args = {})
      super(args)

      @name = @properties[:name]
      @attrs = @properties[:attrs]
      @line_num = @properties[:line_num]
      @parent = @properties[:parent]
    end

    def resource_name
      @parent.resource_name unless @parent.nil?
    end

    def to_s
      resource = @parent
      return "#{resource.to_s}/#{@name}"
    end
  end
end