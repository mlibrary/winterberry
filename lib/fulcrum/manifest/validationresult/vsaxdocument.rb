module UMPTG::Fulcrum::Manifest::ValidationResult
  class VSaxDocument < Nokogiri::XML::SAX::Document
    attr_accessor :line_num, :root, :line_map

    def initialize
      reset()
    end

    def start_element(name, attrs = [])

      args = {
            :name => name,
            :attrs => attrs,
            :line_num => @line_num
      }

      case
      when name == 'monograph'
        n  = VMNode.new(args)
        @current_monograph = n
        n.parent = nil
      when name == 'resource_type'
        @in_resources = true
      when UMPTG::Fulcrum::Manifest::Validation::CollectionSchema.resource?(name)
        n  = VRNode.new(args)
        @current_resource = n
        n.parent = @current_monograph
      else
        if @in_resources and @current_resource.nil?
          n  = VRNode.new(args)
          @current_resource = n
          n.parent = @current_monograph
        else
          # Property
          n = VNode.new(args)
          n.parent = @current_resource
        end
      end

      @line_map[@line_num] = n

      #puts "Line: #{@line_num}  starting: #{name}"
    end

    def end_element name
      #puts "ending: #{name}"
      if @in_resources
        if name == 'resource_type'
          @in_resources = false
        elsif !@current_resource.nil? and name == @current_resource.name
          @current_resource = nil
        end
      end
    end

    def reset()
      @line_num = 0
      @line_map = {}
      @in_resources = false
      @current_resource = nil
      @current_monograph = nil
    end
  end
end
