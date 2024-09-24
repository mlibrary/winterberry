module UMPTG
  require_relative File.join('epub', 'archive')

  class << self
    def EPUB(args = {})
      return EPUB::Archive::EPUB.new(args)
    end
  end
end
