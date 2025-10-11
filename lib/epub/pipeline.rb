module UMPTG::EPUB

  require_relative File.join('pipeline', 'processor')
  require_relative 'migrator'

  def self.Processor(args = {})
    return Pipeline::Processor.new(args)
  end

  def self.Migrator(args = {})
    a = args.clone
    return Migrator.new(a)
  end

  def self.Reviewer(args = {})
    a = args.clone
    a[:options] = {
                    xhtml_img_alttext: true,
                    xhtml_extdescr: true
                  }
    return Processor(a)
  end
end
