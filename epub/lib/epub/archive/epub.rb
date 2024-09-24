module UMPTG::EPUB::Archive

  class EPUB < UMPTG::Object
    attr_reader :files, :container

    def initialize(args = {})
      super(args)

      a = args.clone
      a[:epub] = self
      @files = Files.new(a)

      @files.load(args)
      @container = @files.container()
    end

    def rendition(args = {})
      return @container.rendition(args)
    end

    def save(args = {})
      modified_date = Time.now.strftime("%Y-%m-%dT%H:%M:%S") + "Z"
      rendition.metadata.dc.terms.modified(meta_property_value: modified_date)
      @files.save(args)
    end
  end
end
