module UMPTG::Fulcrum::Resources::XHTML
  require_relative(File.join("pipeline", "filter"))
  require_relative(File.join("pipeline", "resourceprocessor"))

  def self.Processor(args = {})
    return Pipeline::ResourceProcessor.new(
              name: args[:name],
              filters: args[:filters],
              options: args[:options],
              logger: args[:logger]
          )
  end
end
