module UMPTG
  require_relative File.join('..', '..', 'lib', 'object')
=begin
  require_relative File.join('epub', 'entry')
  require_relative File.join('epub', 'archive')
  require_relative File.join('epub', 'manifest')
  require_relative File.join('epub', 'spine')
  require_relative File.join('epub', 'navigation')
  require_relative File.join('epub', 'rendition')
  require_relative File.join('epub', 'epub')
=end

  require_relative File.join('epub_new', 'node')
  require_relative File.join('epub_new', 'entry')
  require_relative File.join('epub_new', 'opfentry')
  require_relative File.join('epub_new', 'archive')
  require_relative File.join('epub_new', 'container')
  require_relative File.join('epub_new', 'rootfiles')
  require_relative File.join('epub_new', 'rendition')
  require_relative File.join('epub_new', 'manifest')
  require_relative File.join('epub_new', 'spine')
  require_relative File.join('epub_new', 'navigation')
  require_relative File.join('epub_new', 'toc')
  require_relative File.join('epub_new', 'epub')

  class << self
    def EPUB(args = {})
      return EPUB::EPUB.new(args)
    end
  end
end
