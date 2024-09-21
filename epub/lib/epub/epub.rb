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

    def save(args = {})
      @archive.save(args)
    end
  end
end
