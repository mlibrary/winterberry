class ElementInfo
  attr_reader :name, :attrs, :file_name
  attr_accessor :caption

  def initialize(p_file_name, p_name, p_attrs = [], p_caption = '')
    @file_name = p_file_name
    @name = p_name
    @attrs = p_attrs
    @caption = p_caption
  end
end
