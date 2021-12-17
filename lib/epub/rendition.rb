module UMPTG::EPUB

  require 'nokogiri'

  class Rendition < UMPTG::Object
    attr_accessor :name, :opf_doc

    @@PKG_TEMPLATE = <<-PKG
    <?xml version="1.0" encoding="UTF-8"?>
    <package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="pub-id" dir="ltr" xml:lang="en">
    <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf"></metadata>
    <manifest></manifest>
    <spine toc="ncx"></spine>
    </package>
    PKG

    def initialize(args = {})
      super(args)
      @name = @properties[:name]
      load()
    end

    def load()
      content = @properties[:content]
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
      return @opf_doc.root.xpath("./*[local-name()='manifest']/*[local-name()='item']")
    end

    def spine
      manifest_items = manifest_map()
      spine = []
      @opf_doc.root.xpath("./*[local-name()='spine']/*[local-name()='itemref']").each do |node|
        ref = node['idref']
        mitem = manifest_items[ref]
        raise "Invalid spine item #{ref}" if mitem.nil?
        spine << mitem
      end
      return spine
    end

    def nav_items
      return manifest.select do |node|
        unless node['properties'].nil?
          (' ' + node['properties'].downcase + ' ').include?(' nav ')
        end
      end
    end

    def ncx_items
      return find_media_type('application/x-dtbncx+xml')
    end

    def css_items
      return find_media_type('text/css')
    end

    private

    def manifest_map
      manifest_items = {}
      manifest.each do |node|
        manifest_items[node['id']] = node
      end
      return manifest_items
    end

    def find_media_type(media_type)
      return manifest.select {|node| node['media-type'].downcase == media_type}
    end

  end
end
