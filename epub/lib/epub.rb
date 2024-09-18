module UMPTG
  require_relative File.join('..', '..', 'lib', 'object')

  folder = 'epub'
  require_relative File.join(folder, 'entry')
  require_relative File.join(folder, 'rendition')
  require_relative File.join(folder, 'archive')
  require_relative File.join(folder, 'epub')

  class << self
    def EPUB(args = {})
      return EPUB::Archive.new(args)
    end
  end
end
