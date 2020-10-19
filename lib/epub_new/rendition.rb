module UMPTG::EPUB_NEW

  require 'nokogiri'

  class Rendition
    attr_reader :opf_item, :spine

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
      content = ""
      if args.key?(:content)
        content = args[:content]
      end
      content = @@PKG_TEMPLATE if content.empty?

      @opf_doc = Nokogiri::XML::Document.parse(content)

      @manifest = {}
      @opf_doc.root.xpath("./*[local-name()='manifest']/*[local-name()='item']").each do |item|
        @manifest[item['id']] = item
      end

      @spine = []
      @opf_doc.root.xpath("./*[local-name()='spine']/*[local-name()='itemref']").each do |itemref|
        ref = itemref['idref']
        @spine << @manifest[ref]
      end
    end

    def version
      return @opf_doc.root['version']
    end

    def manifest
      return @manifest.values
    end
  end
end
