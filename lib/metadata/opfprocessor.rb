# Class for retrieving HTML image elements.
# Adds element name and attributes into a list.
# Also, attempt to retrieve the image caption.

require "nokogiri"

require_relative 'opfinfo'

class OPFProcessor < Nokogiri::XML::SAX::Document
  attr_reader :opf_info

  def initialize(p_opf_info = OPFInfo.new)
    @opf_info = p_opf_info
    @current_attrs = nil
    @current_content = nil
    @cover_id = nil
  end

  def start_element(name, attrs = [])
    #puts "<#{name}: #{attrs.map {|x| x.inspect}.join(', ')}>"

    @current_attrs = attrs

    attrs_h = attrs.to_h

    if name[0..2] == 'dc:'
      @current_content = ""
    elsif name == 'meta' and attrs_h.has_key?('name')
      @opf_info.args[attrs_h['name']] = attrs_h['content']
      if attrs_h['name'] == 'cover'
        @cover_id = attrs_h['content']
      end
    elsif name == 'meta' and attrs_h.has_key?('property')
      @current_content = ""
    end
  end

  def end_element(name)
    attrs_h = @current_attrs.to_h

    case name
    when 'item'
      if attrs_h.has_key?('id') and attrs_h['id'] == @cover_id
        @opf_info.args["cover_href"] = attrs_h['href']
      end
    else
      if @current_content != nil
        prop = name == 'meta' ? attrs_h['property'] : name
        #puts "Prop: #{name} => #{prop}"
        #@opf_info.args[prop] = @current_content
        if @opf_info.args.has_key?(prop)
          @opf_info.args[prop] += ';' + @current_content
        else
          @opf_info.args[prop] = @current_content
        end
      end
    end
    @current_attrs = nil
    @current_content = nil
  end

  def characters(string)
    if @current_content != nil
      @current_content += string
    end
  end
end
