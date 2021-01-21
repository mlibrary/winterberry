module UMPTG
  require_relative 'epub'
  require_relative 'xmlutil'

  require_relative File.join('keywords', 'speckeywordselector')
  require_relative File.join('keywords', 'referenceprocessor')
  require_relative File.join('keywords', 'action')
  require_relative File.join('keywords', 'linkkeywordaction')
  require_relative File.join('keywords', 'keywordprocessor')
  require_relative File.join('keywords', 'epubkeywordprocessor')
end
