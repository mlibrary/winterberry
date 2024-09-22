module UMPTG::EPUB

  class EPUB < UMPTG::Object
    attr_reader :archive, :container

    def initialize(args = {})
      super(args)

      a = args.clone
      a[:epub] = self
      @archive = Archive.new(a)
      @container = archive.container()
    end

    def rendition
      return @container.rendition
    end

    def save(args = {})
      modified_date = Time.now.strftime("%Y-%m-%dT%H:%M:%S") + "Z"
      @container.rendition.metadata.dc.dcterms_modified(metadata_value: modified_date)
      @archive.save(args)
    end
  end
end
