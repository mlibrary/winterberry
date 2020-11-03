module UMPTG::EPUB_NEW

  require 'nokogiri'

  class Rendition
    attr_accessor :name

    @@PKG_TEMPLATE = <<-PKG
    <?xml version="1.0" encoding="UTF-8"?>
    <package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="pub-id" dir="ltr" xml:lang="en">
    <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf"></metadata>
    <manifest></manifest>
    <spine toc="ncx"></spine>
    </package>
    PKG

    def initialize(args = {})
      load(args)
    end

    def load(args = {})
      @name = args[:name]
      content = args[:content]
      content = @@PKG_TEMPLATE if content.nil? or content.empty?

      @opf_doc = Nokogiri::XML::Document.parse(content)
    end

    def opf_to_s
      return UMPTG::XMLUtil.doc_to_xml(@opf_doc)
    end

    def version(ver = '')
      if ver.nil? or ver.empty?
        ver = @opf_doc.root['version']
      else
        @opf_doc.root['version'] = ver
      end
      return ver
    end

    def manifest
      manifest = {}
      @opf_doc.root.xpath("./*[local-name()='manifest']/*[local-name()='item']").each do |node|
        manifest[node['id']] = node
      end
      return manifest.values
    end

    def spine
      spine = []
      @opf_doc.root.xpath("./*[local-name()='spine']/*[local-name()='itemref']").each do |node|
        ref = node['idref']
        spine << @manifest[ref]
      end
      return spine
    end

    def nav_items
      return manifest.select do |node|
        unless node['properties'].nil?
          ' ' + node['properties'].downcase + ' '.include?(' nav ')
        end
      end
    end

    def ncx_items
      return manifest.select {|node| node['media-type'].downcase == 'application/x-dtbncx+xml'}
    end
  end
end
