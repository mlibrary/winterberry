module UMPTG
  require_relative 'message'
  require_relative 'fragment'
  require_relative 'epub'

  require_relative File.join('review', 'action')
  require_relative File.join('review', 'figureaction')
  require_relative File.join('review', 'imgaction')
  require_relative File.join('review', 'linkaction')
  require_relative File.join('review', 'listaction')
  require_relative File.join('review', 'packagemetadataaction')
  require_relative File.join('review', 'packagemanifestaction')
  require_relative File.join('review', 'packageaction')
  require_relative File.join('review', 'tableaction')
  require_relative File.join('review', 'entryprocessor')
  require_relative File.join('review', 'figureprocessor')
  require_relative File.join('review', 'imgprocessor')
  require_relative File.join('review', 'linkprocessor')
  require_relative File.join('review', 'listprocessor')
  require_relative File.join('review', 'packagemetadataprocessor')
  require_relative File.join('review', 'packagemanifestprocessor')
  require_relative File.join('review', 'packageprocessor')
  require_relative File.join('review', 'tableprocessor')
end
