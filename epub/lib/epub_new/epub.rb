module UMPTG::EPUB

  class EPUB < UMPTG::Object
    attr_reader :archive

    def initialize(args = {})
      super(args)

      a = args.clone
      a[:epub] = self
      @archive = Archive.new(a)
      @container = nil
    end

    def container()
      @container = @archive.container if @container.nil?
      return @container
    end

    def save(args = {})
      @archive.save(args)
    end
  end
end
