module UMPTG::Fulcrum
  require_relative 'resourcemap'

  require_relative File.join('resources', 'xhtml')

  def self.ResourceProcessor(args = {})
    a = args.clone

    # Enable default filter if none specified.
    a[:options] = { xhtml_embed_link: true } if a[:options].nil?

    unless args[:manifest].nil?
      a[:xhtml_processor] = UMPTG::Fulcrum::Resources::XHTML::Processor(
                name: "FulcrumResourceProcessor",
                manifest: a[:manifest],
                options: a[:options]
          )
    end
    return UMPTG::EPUB::Processor(a)
  end
end
