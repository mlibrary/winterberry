module UMPTG
  require_relative 'logger'
  require_relative 'xml'
  require_relative 'xslt'
  require_relative 'object'
  require_relative 'action'
  require_relative 'fragment'

  require_relative File.join('epub_v1', 'util')
  require_relative File.join('epub_v1', 'entry')
  require_relative File.join('epub_v1', 'entryactions')
  require_relative File.join('epub_v1', 'rendition')
  require_relative File.join('epub_v1', 'archive')
  require_relative File.join('epub_v1', 'echeck')
  require_relative File.join('epub_v1', 'migrator')
  require_relative File.join('epub_v1', 'entryprocessor')
  require_relative File.join('epub_v1', 'processor')
  require_relative File.join('epub_v1', 'xprocessor')

  class << self
    def EPUB(args = {})
      return EPUB::Archive.new(args)
    end
  end
end
