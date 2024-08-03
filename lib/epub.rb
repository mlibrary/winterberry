module UMPTG
  require_relative 'logger'
  require_relative 'xml'
  require_relative 'xslt'
  require_relative 'object'
  require_relative 'action'
  require_relative 'fragment'

  require_relative File.join('epub', 'util')
  require_relative File.join('epub', 'entry')
  require_relative File.join('epub', 'entryactions')
  require_relative File.join('epub', 'rendition')
  require_relative File.join('epub', 'archive')
  require_relative File.join('epub', 'migrator')
  require_relative File.join('epub', 'entryprocessor')
  require_relative File.join('epub', 'processor')
  require_relative File.join('epub', 'xprocessor')

  class << self
    def EPUB(args = {})
      return EPUB::Archive.new(args)
    end
  end
end
