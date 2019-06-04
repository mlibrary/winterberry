require "nokogiri"

class HTMLParser < Nokogiri::XML::SAX::Document

    def initialize(p_processor)
      @processor = p_processor
    end

    def start_element(name, attrs = [])
        #puts "<#{name}: #{attrs.map {|x| x.inspect}.join(', ')}"
        @processor.start_element(name, attrs)
    end

    def characters(string)
        #return if string =~ /^\w*$/     # whitespace only
        @processor.characters(string)
    end

    def end_element(name)
      @processor.end_element(name)
    end
end

