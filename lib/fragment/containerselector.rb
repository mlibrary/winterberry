module UMPTG::Fragment

  # Class selects XML fragments.
  class ContainerSelector < Selector

    attr_accessor :containers, :attribute_name, :attribute_values

    def initialize()
      @containers = []
      @attribute_name = ""
      @attribute_values = []
    end

    def select_fragment(name, attrs = [])
      raise "Error: ContainerSelector - no containers specified." if @containers.empty?

      if @containers.include?(name)
        # Element is a desired container.
        return true if @attribute_name.strip.empty?

        # If specific attribute is specified, see if
        # this element has that attribute set.
        attrs_map = attrs.to_h
        if attrs_map.key?(@attribute_name)
          # Has specific attribute, see if value
          # is one specified in the list.
          return true if @attribute_values.empty?

          attrs_map[@attribute_name].strip.split(' ').each do |attrval|
            return true if @attribute_values.include?(attrval)
          end
        end
      end
      return false
    end
  end
end
