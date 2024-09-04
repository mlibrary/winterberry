module UMPTG::Fulcrum::Resources

  class << self
    def EPUBProcessor(args = {})
      return EPUBProcessor.new(args)
    end
  end

  require_relative(File.join("..", "..", "css"))

  class EPUBProcessor < UMPTG::EPUB::XProcessor

    def run(epub, args = {})
      entry_actions = super(epub, args)

      if epub.modified and xml_processor.options[:embed_link]
        epub.add(
              entry_name: "OEBPS/styles/fulcrum_default.css",
              entry_content: UMPTG::CSS.fulcrum_default(),
              media_type: "text/css"
            )
      end

      return entry_actions
    end
  end
end
