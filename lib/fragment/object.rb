module UMPTG::Fragment

  # Class represents a selected fragment.
  class Object
    attr_reader :node, :name

    def initialize(args = {})
      # Fragment consist of a container XML node and
      # a name to associate with the fragment provided
      # by the caller.
      @node = args[:node]
      @name = args[:name]
    end

    def map
      row = {}
      @node.each do |attr,value|
        row[attr] = value
      end
      return row
    end
  end
end
