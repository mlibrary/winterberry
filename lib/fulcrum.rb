module UMPTG
  require_relative 'epub'
  require_relative 'resources'
  require_relative 'keywords'

  require_relative File.join('fulcrum', 'manifest')
  require_relative File.join('fulcrum', 'metadata')
  require_relative File.join('fulcrum', 'resourcemap')
  require_relative File.join('fulcrum', 'epubprocessor')
end
