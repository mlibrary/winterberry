class XMLUtil
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

  def self.save_html(doc, dest_path)
    puts "Writing #{dest_path}"

    xml_header = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    begin
      # doc.to_xml would include <!DOCTYPE html> header.
      File.write(dest_path, xml_header + doc.xpath("//*[local-name()='html']").to_s)
    rescue Exception => e
      puts e.message
    end
  end

  def self.save(doc, dest_path)
    puts "Writing #{dest_path}"

    xml_header = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    begin
      # doc.to_xml would include <!DOCTYPE html> header.
      File.write(dest_path, xml_header + doc.xpath("/*").to_s)
    rescue Exception => e
      puts e.message
    end
  end
end