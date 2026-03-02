module UMPTG::EPUB

  require_relative(File.join("..", "pipeline"))
  require_relative(File.join('pipeline', 'processor'))
  require_relative('migrator')
  require_relative('reviewer')
  require_relative('timesfontprocessor')

  def self.Processor(args = {})
    return Pipeline::Processor.new(
              name: args[:name],
              filters: args[:filters],
              options: args[:options],
              logger: args[:logger]
            )
  end

  def self.Migrator(args = {})
    a = args.clone
    return Migrator.new(a)
  end

  def self.Reviewer(args = {})
    a = args.clone
    return Reviewer.new(a)
  end

  def self.TimesFontProcessor(args = {})
    a = args.clone
    return TimesFontProcessor.new(a)
  end
end
