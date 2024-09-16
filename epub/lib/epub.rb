module UMPTG
  require_relative File.join('..', '..', 'lib', 'object')

  require_relative File.join('epub', 'entry')
  require_relative File.join('epub', 'rendition')
  require_relative File.join('epub', 'archive')

  class << self
    def EPUB(args = {})
      return EPUB::Archive.new(args)
    end
  end
end
