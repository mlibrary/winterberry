module UMPTG::Fulcrum
  require_relative 'resourcemap'

  require_relative File.join('resources', 'xhtml')

  def self.ResourceProcessor(args = {})
    a = args.clone

    # Enable default filter if none specified.
    options = { xhtml_embed_link: true } if a[:options].nil?

    unless args[:manifest].nil?
      options[:manifest] = args[:manifest]
      options[:xhtml_processor] = UMPTG::Fulcrum::Resources::XHTML::Processor(
                name: "FulcrumResourceProcessor",
                options: options
          )
    end
    a[:options] = options
    return UMPTG::EPUB::Processor(a)
  end
end
