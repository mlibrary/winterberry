module UMPTG::EPUB

  class EPUB < UMPTG::Object
    attr_reader :archive, :container

    def initialize(args = {})
      super(args)

      a = args.clone
      a[:epub] = self
      @archive = Archive::Archive.new(a)

      @archive.load(args)
      @container = archive.container()
    end

    def rendition(args = {})
      return @container.rendition(args)
    end

    def save(args = {})
      modified_date = Time.now.strftime("%Y-%m-%dT%H:%M:%S") + "Z"
      rendition.metadata.dc.terms.modified(meta_property_value: modified_date)
      @archive.save(args)
    end
  end
end