class VTree
  def initialize(args = {})
    @line_map = args[:line_map]
  end

  def resource(line_num)
    n = @line_map[line_num]
    return n.parent unless n.nil?

    puts "Line: #{error.line} no resource"
    return nil
  end

  def property(line_num)
    n = @line_map[line_num]
    return n unless n.nil?

    puts "Line: #{line_num} no property"
    return nil
  end
end
