module UMPTG
  require_relative 'message'
  require_relative 'fragment'
  require_relative 'epub'

  require_relative File.join('review_version1', 'action')
  require_relative File.join('review_version1', 'figureaction')
  require_relative File.join('review_version1', 'imgaction')
  require_relative File.join('review_version1', 'linkaction')
  require_relative File.join('review_version1', 'listaction')
  require_relative File.join('review_version1', 'packagemetadataaction')
  require_relative File.join('review_version1', 'packagemanifestaction')
  require_relative File.join('review_version1', 'packageaction')
  require_relative File.join('review_version1', 'tableaction')
  require_relative File.join('review_version1', 'entryprocessor')
  require_relative File.join('review_version1', 'figureprocessor')
  require_relative File.join('review_version1', 'imgprocessor')
  require_relative File.join('review_version1', 'linkprocessor')
  require_relative File.join('review_version1', 'listprocessor')
  require_relative File.join('review_version1', 'packagemetadataprocessor')
  require_relative File.join('review_version1', 'packagemanifestprocessor')
  require_relative File.join('review_version1', 'packageprocessor')
  require_relative File.join('review_version1', 'tableprocessor')
end
