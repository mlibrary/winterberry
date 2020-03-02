require "nokogiri"

class FragmentSaxDocument < Nokogiri::XML::SAX::Document

  attr_accessor :containers, :info, :name
  attr_reader :fragments

  def initialize(args = {})
    @containers = args[:containers] if args.has_key?(:containers)
    @info = args[:info] if args.has_key?(:info)
    @name = args[:name]
    reset
  end

  def start_element(name, attrs = [])
    #puts "<#{name}: #{attrs.map {|x| x.inspect}.join(', ')}>"
    return unless @containers.include?(name) or @fragment_refcnt > 0

    @fragment_refcnt += 1 if @containers.include?(name)
    str = "<#{name}"
    attrs.to_h.each {|k,v| str += " #{k}=\"#{v}\""}
    str += ">"
    @fragment_markup += str
  end

  def end_element(name)
    @fragment_markup += "</#{name}>" if @fragment_refcnt > 0
    if @containers.include?(name)
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

  def characters(string)
    @fragment_markup += string if @fragment_refcnt > 0
  end

  def reset
    @fragments = []
    @fragment_refcnt = 0
    @fragment_markup = ""
  end
end
