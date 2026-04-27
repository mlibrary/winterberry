module UMPTG::Fulcrum
  require_relative 'resourcemap'

  require_relative File.join('resources', 'xhtml')

  def self.ResourceProcessor(name, manifest: nil, options: {}, logger: nil)
    return UMPTG::EPUB::ResourceProcessor.new(
            name,
            manifest,
            options: options,
            logger: logger
          )
  end
end
