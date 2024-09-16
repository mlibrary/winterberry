module UMPTG::EPUB

  require 'zip/filesystem'
  require 'nokogiri'

  class Archive < UMPTG::Object


    CONTAINER_XML =  <<-CONXML
<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
<rootfiles></rootfiles>
</container>
    CONXML

    ROOTFILE_XML = '<rootfile full-path="%s" media-type="application/oebps-package+xml"/>'

    def initialize(args = {})
      super(args)

      @entries = []
      @renditions = {}

      a = args.clone
      case
      when args.key?(:epub_file)
        #load_file(a)
      else
        load(a)
      end
    end

    def add_entry(args = {})
      entry = Entry.new(args)
      @entries << entry
    end

    def save(args = {})
      epub_file = args[:epub_file]
      raise "EPUB path must be specified" if epub_file.nil? or epub_file.strip.empty?

      Zip::OutputStream.open(epub_file) do |zos|
        # Make the mimetype the first item
        Entry.write(
            zos,
            entry_name: "mimetype",
            entry_content: "application/epub+zip",
            compression_method: Zip::Entry::STORED
          )

        # Write the META-INF/container.xml
        container_doc = Nokogiri::XML(CONTAINER_XML)
        rf = container_doc.xpath("//*[local-name()='rootfiles']").first
        raise "unable to locate rootfiles" if rf.nil?
        @renditions.keys.each {|k| rf.add_child(sprintf(ROOTFILE_XML, File.join("OEBPS", k + ".opf"))) }
        Entry.write(
            zos,
            entry_name: File.join("META-INF", "container.xml"),
            entry_content: container_doc.to_xml
          )

        # Write the renditions
        @renditions.values.each {|rend| rend.write(zos) }
      end
    end

    private

    def load(args = {})
      n = args[:rendition_name]
      if n.nil? or n.strip.empty?
        cnt = @renditions.count
        n = cnt == 0 ? "content" : "content_" + @renditions.count.to_s.rjust(3, '0')
      end
      args[:rendition_name] = n

      rendition = Rendition.new(args)
      @renditions[rendition.name] = Rendition.new(args)
    end
  end
end