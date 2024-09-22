module UMPTG
  require_relative File.join('..', '..', 'lib', 'object')

  require_relative File.join('epub', 'node')
  require_relative File.join('epub', 'archive')
  require_relative File.join('epub', 'metainf')
  require_relative File.join('epub', 'oebps')
  require_relative File.join('epub', 'epub')

  class << self
    def EPUB(args = {})
      return EPUB::EPUB.new(args)
    end
  end
end
