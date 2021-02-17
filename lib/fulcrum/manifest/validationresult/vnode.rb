module UMPTG::Fulcrum::Manifest::ValidationResult
  class VNode
    attr_accessor :name, :attrs, :parent, :line_num

    def initialize(args = {})
      @name = args[:name]
      @attrs = args[:attrs]
      @line_num = args[:line_num]
      @parent = args[:parent]
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