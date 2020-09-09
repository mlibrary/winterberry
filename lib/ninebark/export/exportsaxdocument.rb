class ExportSaxDocument < Nokogiri::XML::SAX::Document
  attr_accessor :elements, :objects, :types, :type_items

  def initialize
    reset()
  end

  def start_element(name, attrs = [])
    #puts "<#{name}: #{attrs.map {|x| x.inspect}.join(', ')}>"

    attrs_h = attrs.to_h

    case
    when name == "xs:element"
      if attrs_h.has_key?('name')
        #puts "Element #{attrs_h['name']}"
        @elements[attrs_h['name']] = attrs_h['type']
      end
    when name == "xs:complexType", name == "xs:simpleType"
      if attrs_h.has_key?('name')
        #puts "Type #{attrs_h['name']}"
        @types[attrs_h['name']] = []
        @current_type = attrs_h['name']
      end
    when name == "xs:attribute"
      if attrs_h['name'] == "object"
        @objects[@current_type] = attrs_h['fixed']
      end
    when name == "xs:enumeration"
      unless @current_type.nil?
        if @type_items.has_key?(@current_type)
          @type_items[@current_type] << attrs_h['value']
        else
          @type_items[@current_type] = [ attrs_h['value'] ]
        end
      end
    when name == "xs:union"
      tlist = attrs_h['memberTypes']
      tlist.split(/[ ]+/).each do |t|
        @types[@current_type] << t
      end
    when attrs_h.has_key?('base')
      unless @current_type.nil?
        @types[@current_type] << attrs_h['base']
      end
    end
  end

  def end_element(name)
    #puts "</#{name}>"
    @current_type = nil if name == "xs:complexType" or name == "xs:simpleType"
  end

  def reset()
    @elements = {}
    @types = {}
    @objects = {}
    @type_items = {}
    @current_type = nil
  end
end
