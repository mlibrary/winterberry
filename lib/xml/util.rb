module UMPTG::XML
  require 'nokogiri'
  require 'htmlentities'

  @@XML_PI = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  @@XML_PI_FORMAT = "<?xml version=\"1.0\" encoding=\"%s\"?>"
  @@HTML_DT = "<!DOCTYPE html>"

  @@ENTITY_CODER = HTMLEntities.new

  def self.parse(args = {})
    xml_content = args[:xml_content]
    if xml_content.nil? or xml_content.empty?
      xml_file = args[:xml_file]
      raise "error: either :xml_content or :xml_file must be provided" \
          if xml_file.nil? or xml_file.empty?

      encoding_name = args[:encoding] || "UTF-8"
      enc = Encoding::find(encoding_name)
      raise "invalid encoding name #{encoding_name}" if enc.nil?

      xml_content = File.open(xml_file, "r", encoding: enc.name) {|fp| fp.read }

      xml_content = UMPTG::XML.remove_bom(xml_content)
=begin
      # Remove BOM from content if present.
      bom = xml_content[0].each_byte.map { |b| b.to_s(16) }.join
      xml_content = xml_content[1..-1] if bom.downcase == "efbbbf"
=end
      unless xml_content[0..200].match?(/<\?xml[ ]*[^\?]+\?>/)
        pi = sprintf(@@XML_PI_FORMAT, enc.name)
        xml_content = pi + "\n" + xml_content
      end
    end

=begin
    begin
      xml_content = @@ENTITY_CODER.decode(xml_content)
    rescue Encoding::UndefinedConversionError => uce
      raise "Encoding error #{uce.message}"
    rescue Exception => e
      raise e.message
    end
=end


    begin
      xml_doc = Nokogiri::XML(xml_content)
    rescue Exception => e
      raise e.message
    end
    return xml_doc
  end

  def self.remove_bom(content = "")
    # Remove BOM from content if present.
    unless content.nil? or content.strip.empty?
      bom = content[0].each_byte.map { |b| b.to_s(16) }.join
      content = content[1..-1] if bom.downcase == "efbbbf"
    end
    return content
  end

  def self.XML_PI(args = {})
    encoding = args[:encoding]
    encoding = 'UTF-8' if encoding.nil? or encoding.strip.empty?
    return sprintf(@@XML_PI_FORMAT, encoding)
  end

  def self.ENTITY_CODER
    return @@ENTITY_CODER
  end

  def self.doc_to_xml(doc)
    pref = @@XML_PI + "\n"
    #pref += @@HTML_DT + "\n" if doc.root.name.downcase == "html"
    return  pref + doc.xpath("/*").to_s
  end

  def self.doc_to_xhtml(doc)
    return UMPTG::XML.doc_to_xml(doc)
  end

  def self.save(doc, dest_path)
    begin
      # doc.to_xml would include <!DOCTYPE html> header.
      File.write(dest_path, UMPTG::XML.doc_to_xml(doc))
    rescue Exception => e
      puts e.message
    end
  end

  def self.save_html(doc, dest_path)
    begin
      # doc.to_xml would include <!DOCTYPE html> header.
      File.write(dest_path, UMPTG::XML.doc_to_xhtml(doc))
    rescue Exception => e
      puts e.message
    end
  end

  def self.add_css(doc, href)
      head_element_list = doc.xpath("/*[local-name()='html']/*[local-name()='head']")
      if head_element_list != nil
        link_element = doc.create_element("link",
                :href => href,
                :rel => "stylesheet",
                :type => "text/css"
                )

        head_element = head_element_list[0]
        link_element_list = head_element.xpath(".//*[local-name()='link']")

        if link_element_list == 0
          child = head_element.first_element_child
          if child == nil
            head_element.add_child(link_element)
          else
            child.add_previous_sibling(link_element)
          end
        else
          child = link_element_list.last
          child.add_next_sibling(link_element)
        end
      end
  end
end
