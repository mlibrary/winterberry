require "nokogiri"

class FragmentSaxDocument < Nokogiri::XML::SAX::Document

  attr_accessor :info, :name
  attr_reader :fragments

  def initialize(args = {})
    @info = args[:info] if args.has_key?(:info)
    @name = args[:name]
    reset
  end

  def start_element(name, attrs = [])
    #puts "<#{name}: #{attrs.map {|x| x.inspect}.join(', ')}>"

    select_frag = select_fragment(name, attrs)
    return unless @fragment_refcnt > 0 or select_frag

    if select_frag
      @fragment_refcnt += 1
      @stack << StackEntry.new(name, attrs)
    end

    str = "<#{name}"
    attrs.to_h.each {|k,v| str += " #{k}=\"#{v}\""}
    str += ">"
    @fragment_markup += str
  end

  def end_element(name)
    @fragment_markup += "</#{name}>" if @fragment_refcnt > 0

    unless @stack.empty?
      if name == @stack.last.name and select_fragment(name, @stack.last.attrs)
        @stack.pop
        @fragment_refcnt -= 1
        if @fragment_refcnt == 0
          fragment = Nokogiri::XML::DocumentFragment.parse(@fragment_markup)
          container = fragment.xpath("./*[1]").first
          @fragments << @info.new_info(
                :node => container,
                :name => @name
              )
          @fragment_markup = ""
        end
      end
    end
  end

  def characters(string)
    s = string.gsub(/[\n\r ]+/, ' ')
    @fragment_markup += s if @fragment_refcnt > 0
  end

  def comment(string)
    s = string.gsub(/[\n\r ]+/, ' ')
    @fragment_markup += "<!--#{s}-->" if @fragment_refcnt > 0
  end

  def select_fragment(name, attrs = [])
    return false
  end

  def reset
    @fragments = []
    @fragment_refcnt = 0
    @fragment_markup = ""

    @stack = []
  end
end

class StackEntry
  attr_reader :name, :attrs
  def initialize(n, a = [])
    @name = n
    @attrs = a
  end
end