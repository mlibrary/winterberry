require_relative 'elementinfo'

class FigureProcessor < Processor
  attr_reader :info_list

  def initialize(p_info_list = [])
    @info_list = p_info_list
    @figcap_stack = []
    @fig_caption = ''
  end

  def start_element(name, attrs = [])
    #puts "<#{name}: #{attrs.map {|x| x.inspect}.join(', ')}>"

    attrs_h = attrs.to_h
    if attrs_h.has_key?('alt')
      # This element has @alt, so grab it.
      @info_list << ElementInfo.new(name, attrs)
    end

    clss = attrs_h['class']
    if @figcap_stack.count > 0 or (attrs_h.has_key?('class') and (clss == 'figcap' or clss == 'figh'))
      # This element is a caption, so prepare to grab its text content.
      @figcap_stack.push(name)
    end
  end

  def end_element(name)
    if @figcap_stack.count > 0
      # Within a figure caption
      @figcap_stack.pop

      if @figcap_stack.empty? and !@info_list.empty?
        # If reach end of caption, save it with
        # last element info.
        @info_list.last.caption = @fig_caption
        @fig_caption = ''
      end
    end
  end

  def characters(string)
    if @figcap_stack.count > 0
      # Within a figure caption. Save the text.
      @fig_caption += string
    end
  end
end