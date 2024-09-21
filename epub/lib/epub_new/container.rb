module UMPTG::EPUB

  class Container < UMPTG::Object
    attr_reader :epub, :renditions

    CONTAINER_PATH = File.join("META-INF", "container.xml")

    CONTAINER_XML = <<-CONXML
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
<rootfiles/>
</container>
    CONXML

    def initialize(args = {})
      super(args)

      @epub = args[:epub]
      @entry = args[:entry]

      @rootfiles = nil
      @renditions = nil
    end

    def aentry
      @entry = @epub.archive.add(
            entry_name: CONTAINER_PATH,
            entry_content: CONTAINER_XML
          ) if @entry.nil?
      return @entry
    end

    def rootfiles
      @rootfiles = RootFiles.new(container: self) if @rootfiles.nil?
      return @rootfiles
    end

    def rendition(args = {})
      rendition_name = args[:rendition_name]
      rendition_name = rendition_name.nil? ? "" : rendition_name.strip

      @renditions = init_renditions() if @renditions.nil?

      return @renditions.first if rendition_name.empty?
      return @renditions.find {|r| r.name == rendition_name }
    end

    def add(args = {})
      rend = nil
      rf = rootfiles.add(args)
      unless rf.nil?
        entry = @epub.archive.find(entry_name: rf['full-path'])
        rend = Rendition.new(
              epub: @epub,
              entry: entry
            )
        @renditions << rend
      end
      return entry
    end

    def self.CONTAINER_PATH
      return CONTAINER_PATH
    end

    private

    def init_renditions()
      rends = []
      if rootfiles.children.empty?
        rends << Rendition.new(epub: epub)
      else
        rends = rootfiles.children.collect do |r|
          entry = @epub.archive.find(entry_name: r['full-path'])
          Rendition.new(
                epub: @epub,
                entry: entry
              )
        end
      end
      return rends
    end
  end
end
