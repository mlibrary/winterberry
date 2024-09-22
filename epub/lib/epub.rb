module UMPTG
  require_relative File.join('..', '..', 'lib', 'object')

  require_relative File.join('epub', 'node')
  require_relative File.join('epub', 'archiveentry')
  require_relative File.join('epub', 'archive')
  require_relative File.join('epub', 'container')
  require_relative File.join('epub', 'rootfiles')
  require_relative File.join('epub', 'rendition')
  require_relative File.join('epub', 'manifest')
  require_relative File.join('epub', 'metadata')
  #require_relative File.join('epub', 'property')
  require_relative File.join('epub', 'terms')
  require_relative File.join('epub', 'dc')
  require_relative File.join('epub', 'dcelements')
  require_relative File.join('epub', 'dcterms')
  require_relative File.join('epub', 'schema')
  require_relative File.join('epub', 'schematerms')
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
