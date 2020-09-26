module UMPTG
  require_relative 'fragment'

  require_relative File.join('review', 'reviewinfo')
  require_relative File.join('review', 'reviewprocessor')
  require_relative File.join('review', 'figureprocessor')
  require_relative File.join('review', 'imgprocessor')
  require_relative File.join('review', 'linkprocessor')
  require_relative File.join('review', 'listprocessor')
  require_relative File.join('review', 'packagemetadataprocessor')
  require_relative File.join('review', 'packageprocessor')
  require_relative File.join('review', 'tableprocessor')
end
