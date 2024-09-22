module UMPTG::EPUB::MetaInf

  class Container < UMPTG::Object
    attr_reader :entry, :epub, :renditions

    DEFAULT_PATH = File.join("META-INF", "container.xml")

    DEFAULT_XML_TEMPLATE = <<-CONXML
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
<rootfiles>
<rootfile full-path="%s" media-type="application/oebps-package+xml"/>
</rootfiles>
</container>
    CONXML

    def initialize(args = {})
      super(args)

      @epub = args[:epub]
      @entry = args[:archive_entry]

      @rootfiles = RootFiles.new(
              container: self,
              archive_entry: @entry
            )
      @renditions = init_renditions()
    end

    def rendition(args = {})
      return find(args)
    end

    def find(args = {})
      rendition_name = args[:rendition_name]
      rendition_name = rendition_name.nil? ? "" : rendition_name.strip

      rend = @renditions.first
      unless rendition_name.empty?
        r = @renditions.find {|r| r.name == rendition_name }
        rend = r unless r.nil?
      end
      return rend
    end

    def add(args = {})
      rend = nil
      entry = rootfiles.add(args)
      unless entry.nil?
        rend = UMPTG::EPUB::OEBPS::Rendition.new(
              epub: @epub,
              archive_entry: entry
            )
        @renditions << rend
      end
      return rend
    end

    def self.DEFAULT_PATH
      return DEFAULT_PATH
    end

    def self.DEFAULT_XML
      return sprintf(DEFAULT_XML_TEMPLATE, UMPTG::EPUB::OEBPS::Rendition.DEFAULT_PATH)
    end

    private

    def init_renditions()
      return @rootfiles.children.collect do |r|
        entry = @epub.archive.find(entry_name: r['full-path'])
        raise "invalid entry" if entry.nil?
        UMPTG::EPUB::OEBPS::Rendition.new(
              epub: @epub,
              archive_entry: entry
            )
      end
    end
  end
end
