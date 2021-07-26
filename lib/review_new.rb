module UMPTG
  require_relative 'message'
  require_relative 'epub'

  require_relative File.join('review_new', 'action')
  require_relative File.join('review_new', 'imageaction')
  require_relative File.join('review_new', 'normalizefigureaction')
  require_relative File.join('review_new', 'normalizefigurecaptionaction')
  require_relative File.join('review_new', 'normalizeimagecontaineraction')
  require_relative File.join('review_new', 'normalizemarkeraction')
  require_relative File.join('review_new', 'elementselector')
  require_relative File.join('review_new', 'resourcereferenceselector')
  require_relative File.join('review_new', 'resourceprocessor')

end
