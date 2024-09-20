module UMPTG::EPUB

  class EPUB < UMPTG::Object
    attr_reader :name, :renditions

    def initialize(args = {})
      super(args)

      @archive = Archive.new(args)

      @renditions = @archive.renditions().collect {|r| Rendition.new(entry: r) }
    end

    def rendition(args = {})
      rendition_name = args[:rendition_name]
      rendition_name = rendition_name.nil? ? "" : rendition_name.strip

      return @renditions.first if rendition_name.empty?
      return @renditions.collect {|r| r.name == rendition_name }
    end

    def save(args = {})
      @archive.save(args)
    end
  end
end
