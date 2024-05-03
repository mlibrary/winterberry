module UMPTG::Journal

  require 'nokogiri'
  require 'htmlentities'

  class JATS < UMPTG::Object

    JATS_DOCTYPE = <<-JDT
<!DOCTYPE article
  PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.2 20190208//EN" "http://jats.nlm.nih.gov/publishing/1.2/JATS-journalpublishing1-mathml3.dtd">
JDT

    def self.save(jats_doc, dest_path)
      jats_doc.root.add_namespace("xlink", "http://www.w3.org/1999/xlink")
      jats_doc.root['xml:lang'] = 'en' unless jats_doc.root.has_attribute?('xml:lang')

      xml_string = jats_doc.root.to_s
      xml_string = xml_string.sub(/xsi:noNamespaceSchemaLocation=\"[^\"]*\"/, '')
      begin
        File.write(
            dest_path,
            UMPTG::XML.XML_PI + "\n" +
            JATS_DOCTYPE +
            xml_string
            )
      rescue Exception => e
        puts e.message
      end
    end
  end
end
