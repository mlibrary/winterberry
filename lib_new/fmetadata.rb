module UMPTG
  require_relative 'object'
  require_relative 'action'
  require_relative 'epub'

  require_relative '../lib/fragment'

  require_relative File.join('fmetadata', 'figureobject')
  require_relative File.join('fmetadata', 'markerobject')
  require_relative File.join('fmetadata', 'action')
  require_relative File.join('fmetadata', 'figureaction')
  require_relative File.join('fmetadata', 'markeraction')
  require_relative File.join('fmetadata', 'processors')
end
