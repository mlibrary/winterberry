module UMPTG::Fulcrum
  require_relative 'resourcemap'

  require_relative File.join('resources', 'xhtml')

  def self.ResourceProcessor(name, manifest, options: {}, logger: nil)
    # Enable default filter if none specified.
    options = { xhtml_embed_link: true } if options.keys.empty?

    options[:xhtml_processor] = UMPTG::Fulcrum::Resources::XHTML::Processor(
              "FulcrumResourceProcessor",
              manifest,
              options: options
        )

    a = {options: options}
    return UMPTG::EPUB::Processor(a)
  end
end
