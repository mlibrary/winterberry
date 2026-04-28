module UMPTG::EPUB

  require_relative(File.join("..", "pipeline"))
  require_relative(File.join('pipeline', 'processor'))
  require_relative('resourceprocessor')
  require_relative('migrator')
  require_relative('reviewer')
  require_relative('timesfontprocessor')

  def self.Processor(name, processors: {}, filters: nil, options: {}, logger: nil)
    return Pipeline::Processor.new(
              name,
              processors: processors,
              filters: filters,
              options: options,
              logger: logger
            )
  end

  def self.Migrator(name, processors: {}, filters: nil, options: {}, logger: nil)
    return Migrator.new(
                  name,
                  processors: processors,
                  filters: filters,
                  options: options,
                  logger: logger
                )

  end

  def self.Reviewer(name, processors: {}, filters: nil, options: {}, logger: nil)
    return Reviewer.new(
                  name,
                  processors: processors,
                  filters: filters,
                  options: options,
                  logger: logger
                )

  end

  def self.TimesFontProcessor(args = {})
    a = args.clone
    return TimesFontProcessor.new(a)
  end
end
