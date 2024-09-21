module UMPTG
  require_relative File.join('..', '..', 'lib', 'object')
=begin
  require_relative File.join('epubOld', 'entry')
  require_relative File.join('epubOld', 'archive')
  require_relative File.join('epubOld', 'manifest')
  require_relative File.join('epubOld', 'spine')
  require_relative File.join('epubOld', 'navigation')
  require_relative File.join('epubOld', 'rendition')
  require_relative File.join('epubOld', 'epub')
=end

  require_relative File.join('epub', 'node')
  require_relative File.join('epub', 'archiveentry')
  require_relative File.join('epub', 'opfarchiveentry')
  require_relative File.join('epub', 'archive')
  require_relative File.join('epub', 'container')
  require_relative File.join('epub', 'rootfiles')
  require_relative File.join('epub', 'rendition')
  require_relative File.join('epub', 'manifest')
  require_relative File.join('epub', 'spine')
  require_relative File.join('epub', 'navigation')
  require_relative File.join('epub', 'toc')
  require_relative File.join('epub', 'epub')

  class << self
    def EPUB(args = {})
      return EPUB::EPUB.new(args)
    end
  end
end
