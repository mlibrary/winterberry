module UMPTG::XML
  require 'nokogiri'
  require 'htmlentities'

  @@XML_PI = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  @@HTML_DT = "<!DOCTYPE html>"

  @@ENTITY_CODER = HTMLEntities.new

  def self.parse(args = {})
    xml_content = args[:xml_content]
    if xml_content.nil? or xml_content.empty?
      xml_file = args[:xml_file]
      raise "error: either :xml_content or :xml_file must be provided" \
          if xml_file.nil? or xml_file.empty?

      xml_content = File.read(xml_file)
    end
    #xml_content = xml_content.force_encoding("ISO-8859-1").encode("UTF-8")
    xml_content = xml_content.force_encoding("UTF-8")

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
      xml_doc = Nokogiri::XML(xml_content, nil, 'UTF-8')
    rescue Exception => e
      raise e.message
    end
    return xml_doc
  end

  def self.XML_PI
    return @@XML_PI
  end

  def self.ENTITY_CODER
    return @@ENTITY_CODER
  end

  def self.doc_to_xml(doc)
    pref = @@XML_PI + "\n"
    pref += @@HTML_DT + "\n" if doc.root.name.downcase == "html"
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

  def self.XML_PI
    return @@XML_PI
  end
end
