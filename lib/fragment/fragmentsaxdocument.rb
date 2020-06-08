require "nokogiri"

class FragmentSaxDocument < Nokogiri::XML::SAX::Document

  attr_accessor :info, :name, :selector
  attr_reader :fragments

  def initialize(args = {})
    @info = args[:info] if args.has_key?(:info)
    @name = args[:name]
    reset
  end

  def start_element(name, attrs = [])
    #puts "<#{name}: #{attrs.map {|x| x.inspect}.join(', ')}>"

    return unless @fragment_refcnt > 0 or @selector.select_fragment(name, attrs)
    @fragment_refcnt += 1

    str = "<#{name}"
    attrs.to_h.each {|k,v| str += " #{k}=\"#{v}\""}
    str += ">"
    @fragment_markup += str
  end

  def end_element(name)
    return if @fragment_refcnt == 0

    @fragment_markup += "</#{name}>"

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

  def characters(string)
    if @fragment_refcnt > 0
      s = string.gsub(/[\n\r ]+/, ' ')
      @fragment_markup += s
    end
  end

  def comment(string)
    if @fragment_refcnt > 0
      s = string.gsub(/[\n\r ]+/, ' ')
      @fragment_markup += "<!--#{s}-->"
    end
  end

  def reset
    @fragments = []
    @fragment_refcnt = 0
    @fragment_markup = ""
  end
end
