module UMPTG::Fulcrum
  # Current implementation
  require_relative(File.join("..", "xml", "pipeline"))
  require_relative(File.join("..", "services"))

  require_relative File.join('metadata', 'xhtml')
  require_relative File.join('metadata', 'epubprocessor')

  def self.MetadataProcessor(name, options: {}, logger: nil)
    return UMPTG::Fulcrum::Metadata::EPUBProcessor.new(
                name,
                options: options,
                logger: logger
            )
  end
end
