# This file contains a ruby class used for parsing
# the XHTML files that contain a table and determine
# the table/@role attribute has the value "empty".

require "nokogiri"

class EmptyTableParser < Nokogiri::XML::SAX::Document
    def initialize
        @in_tbody = false
        @role_empty = true
    end

    def start_element(name, attrs = [])
        # Handle each element, expecting the name and any attributes
        #puts "<#{name}: #{attrs.map {|x| x.inspect}.join(', ')}>"
        case name
        when "tbody"
          @in_body = true
        when "tr"
          if @in_tbody
            @role_empty = false
          end
        end
    end

    def end_element(name)
      case name
        when "tbody"
          @in_body = false
      end
    end

    def is_empty?
        return @role_empty
    end
end

def is_empty_table?(path)
    empty_table_parser = EmptyTableParser.new
    parser = Nokogiri::XML::SAX::Parser.new(empty_table_parser)
    parser.parse_file(path)
    return empty_table_parser.is_empty?
end


