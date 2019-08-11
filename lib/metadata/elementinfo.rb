class ElementInfo
  attr_reader :name, :attrs
  attr_accessor :caption

  def initialize(p_name, p_attrs = [], p_caption = '')
    @name = p_name
    @attrs = p_attrs
    @caption = p_caption
  end
end
