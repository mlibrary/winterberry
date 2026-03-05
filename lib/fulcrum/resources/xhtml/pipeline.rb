module UMPTG::Fulcrum::Resources::XHTML
  require_relative(File.join("pipeline", "filter"))
  require_relative(File.join("pipeline", "resourceprocessor"))

  def self.Processor(name, manifest, options: {}, logger: nil)
    return Pipeline::ResourceProcessor.new(
              name,
              manifest,
              options: options,
              logger: logger
          )
  end
end
