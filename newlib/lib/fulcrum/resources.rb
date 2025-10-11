module UMPTG::Fulcrum
  require_relative(File.join("..", "..", "..", "lib", "fulcrum", "filter"))

  require_relative(File.join("resources", "xhtml"))

  def self.ResourceProcessor(args = {})
    a = args.clone
    a[:xhtml_processor] = UMPTG::Fulcrum::Resources::XHTML::Processor(
              name: "FulcrumResourceProcessor",
              manifest: args[:manifest],
              options: { xhtml_embed_link: true }
        )
    return UMPTG::EPUB::Processor(a)
  end
end
