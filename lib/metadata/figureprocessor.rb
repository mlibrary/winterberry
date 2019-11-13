# Class for retrieving HTML image elements.
# Adds element name and attributes into a list.
# Also, attempt to retrieve the image caption.

require "nokogiri"

require_relative 'elementinfo'

class FigureProcessor < Nokogiri::XML::SAX::Document
  attr_reader :info_list

  def initialize(p_info_list = [])
    @info_list = p_info_list
    reset
  end

  def start_element(name, attrs = [])
    #puts "<#{name}: #{attrs.map {|x| x.inspect}.join(', ')}>"

    attrs_h = attrs.to_h
    if attrs_h.has_key?('alt')
      # This element has @alt, so grab it.
      @info_list << ElementInfo.new(name, attrs)
    end

    if @figcap_stack.count > 0 or name == 'figcaption' or \
            (attrs_h.has_key?('class') and (attrs_h['class'] == 'figcap' or attrs_h['class'] == 'figh'))
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

  def reset
    @info_list = []
    @figcap_stack = []
    @fig_caption = ''
  end
end
