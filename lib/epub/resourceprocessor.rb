module UMPTG::EPUB

  class ResourceProcessor < UMPTG::EPUB::Pipeline::Processor
    def initialize(name, manifest, filters: nil, options: {}, logger: nil)
      # Enable default filter if none specified.
      options = { xhtml_embed_link: true } if options.keys.empty?

      xhtml_processor = UMPTG::Fulcrum::Resources::XHTML::Processor(
                "FulcrumResourceProcessor",
                options: options
          )
      super(
              name,
              processors: {xhtml_processor: xhtml_processor},
              options: options,
              logger: logger
            )
    end

    def run(epub, manifest, options: {}, logger: nil)
      @xhtml_processor.manifest = manifest
      entry_results = super(
              epub,
              options: options,
              logger: logger
           )
      @xhtml_processor.manifest = nil
      return entry_results
    end
  end
end
