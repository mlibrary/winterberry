module UMPTG::EPUB

  # Class is an interface for processing XML content found
  # wiithin an EPUB.
  class EntryProcessor < UMPTG::Object
    def initialize(args = {})
      super(args)
    end

    # This must be overridden. The base method does nothing.
    def action_list(args = {})
      name = args[:name]
      content = args[:content]

      alist = []
      return alist
    end

    def reset()
    end
  end
end
