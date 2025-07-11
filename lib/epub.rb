module UMPTG
  require_relative File.join('epub', 'archive')
  require_relative File.join('epub', 'entryactions')
  require_relative File.join('epub', 'pipeline')
  require_relative File.join('epub', 'ncx')
  require_relative File.join('epub', 'oebps')
  require_relative File.join('epub', 'util')

  class << self
    def EPUB(args = {})
      return EPUB::Archive::EPUB.new(args)
    end
  end
end
