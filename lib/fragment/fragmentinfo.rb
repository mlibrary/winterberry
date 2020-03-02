class FragmentInfo
  attr_reader :node, :name

  def initialize(args = {})
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
