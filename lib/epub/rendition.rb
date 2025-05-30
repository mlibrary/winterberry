module UMPTG::EPUB

  require 'nokogiri'

  class Rendition < UMPTG::Object
    attr_accessor :name, :opf_doc

    #<spine toc="ncx"></spine>
    @@PKG_TEMPLATE = <<-PKG
    <?xml version="1.0" encoding="UTF-8"?>
    <package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="pub-id" dir="ltr" xml:lang="en">
    <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf">
    <dc:identifier id="pub-id">pubid</dc:identifier>
    </metadata>
    <manifest></manifest>
    <spine></spine>
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
      return UMPTG::XML.doc_to_xml(@opf_doc)
    end

    def version(ver = '')
      if ver.nil? or ver.empty?
        ver = @opf_doc.root['version']
      else
        @opf_doc.root['version'] = ver
      end
      return ver
    end

    def identifiers()
      ident_list = @opf_doc.root.xpath("./*[local-name()='metadata']/*[name()='dc:identifier']")
      identifiers = {}
      ident_list.each {|n| identifiers[n['id']] = n.content.nil? ? "" : n.content.strip }
      return identifiers
    end

    def metadata
      meta = {}
      @opf_doc.root.xpath("./*[local-name()='metadata']/*").each do |n|
        case n.name
        when "meta"
          prop = n['property']
          if meta[prop].nil?
            meta[prop] = [n.content.strip]
          else
            meta[prop] << n.content.strip
          end
        else
          meta[n.name]= n.content
        end
      end
      return meta
    end

    def hasProperty(args = {})
      property = args[:property] || ""
      unless property.empty?
        property_list =  metadata[property] || []
        property_value = (args[:property_value] || "").strip.downcase
        return !property_list.empty? if property_value.empty?

        val_list = property_list.select {|m| m.downcase == property_value }
        return !val_list.empty?
      end
      return false
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

    def xhtml_items
      return find_media_type('application/xhtml+xml') \
          + find_media_type('application/oebps-page-map+xml')
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

    def cover_name
      node_list = @opf_doc.root.xpath("./*[local-name()='metadata']/*[local-name()='meta' and @name='cover']")
      cover_id = node_list.first['content'] unless node_list.empty?
      if cover_id.nil?
        node_list = @opf_doc.root.xpath("./*[local-name()='manifest']/*[local-name()='item' and contains(concat(' ',@properties,' '),' cover-image ')]")
      else
        node_list = @opf_doc.root.xpath("./*[local-name()='manifest']/*[local-name()='item' and @id='#{cover_id}']")
      end
      return node_list.first['href']
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
      m = media_type.downcase
      return manifest.select {|node| node['media-type'].downcase == m}
    end

  end
end
