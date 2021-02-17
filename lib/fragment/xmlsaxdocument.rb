module UMPTG::Fragment

  require "nokogiri"
  require 'htmlentities'

  class XMLSaxDocument < Nokogiri::XML::SAX::Document

    attr_accessor :info, :name, :selector
    attr_reader :fragments

    @@encoder = nil

    def initialize(args = {})
      @name = args[:name]
      reset
    end

    def start_element(name, attrs = [])
      #puts "<#{name}: #{attrs.map {|x| x.inspect}.join(', ')}>"

      return unless @fragment_refcnt > 0 or @selector.select_element(name, attrs)
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
        @fragments << UMPTG::Fragment::Object.new(
              :node => container,
              :name => @name
            )
        @fragment_markup = ""
      end
    end

    def characters(string)
      if @fragment_refcnt > 0
        s = normalize(string)
        @fragment_markup += s
      end
    end

    def comment(string)
      s = normalize(string)
      markup = "<!--#{s}-->"

      case
      when @fragment_refcnt > 0
        @fragment_markup += markup
      when @selector.select_comment(string)
        m = Nokogiri::XML::DocumentFragment.parse("<p>#{markup}</p>")
        f = UMPTG::Fragment::Object.new(
              :node => m,
              :name => name
            )
        @fragments << f
      end
    end

    def reset
      @fragments = []
      @fragment_refcnt = 0
      @fragment_markup = ""
    end

    private

    def normalize(str)
      # Replace newlines with spaces. Replace '<' with XML entity.
      @@encoder = HTMLEntities.new if @@encoder.nil?
      str = str.gsub(/[\n\r ]+/, ' ')
      str = @@encoder.encode(str)
      return str
    end
  end
end
