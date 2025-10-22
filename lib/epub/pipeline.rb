module UMPTG::EPUB

  require_relative File.join('pipeline', 'processor')
  require_relative 'migrator'
  require_relative 'reviewer'

  def self.Processor(args = {})
    return Pipeline::Processor.new(args)
  end

  def self.Migrator(args = {})
    a = args.clone
    return Migrator.new(a)
  end

  def self.Reviewer(args = {})
    a = args.clone
    return Reviewer.new(a)
  end
end
