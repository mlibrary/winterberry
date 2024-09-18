module UMPTG::EPUB

  class EPUB < UMPTG::Object
    def initialize(args = {})
      super(args)

      @archive = Archive.new(args)

      @renditions = @archive.renditions().collect {|r| Rendition.new(entry: r) }
    end

    def save(args = {})
      @archive.save(args)
    end
  end
end
