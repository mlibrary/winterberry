module UMPTG
  require_relative 'epub'
  require_relative 'logger'
  require_relative 'services'
  require_relative 'xmlutil'

  require_relative File.join('fulcrum', 'manifest')
  require_relative File.join('fulcrum', 'metadata')
  require_relative File.join('fulcrum', 'monographdir')
  require_relative File.join('fulcrum', 'referenceactions')
  require_relative File.join('fulcrum', 'referenceactiondef')
  require_relative File.join('fulcrum', 'resourcemap')
  require_relative File.join('fulcrum', 'keywords')
  require_relative File.join('fulcrum', 'resources')
  require_relative File.join('fulcrum', 'epubprocessor')
end
