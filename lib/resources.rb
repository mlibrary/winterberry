module UMPTG
  require_relative 'epub'
  require_relative 'resourcemap'
  require_relative 'xmlutil'

  require_relative File.join('resources', 'referenceactiondef')
  require_relative File.join('resources', 'referenceselector')
  require_relative File.join('resources', 'newgenreferenceselector')
  require_relative File.join('resources', 'specreferenceselector')
  require_relative File.join('resources', 'resourceprocessor')
  require_relative File.join('resources', 'action')
  require_relative File.join('resources', 'embedmarkeraction')
  require_relative File.join('resources', 'linkmarkeraction')
  require_relative File.join('resources', 'noneaction')
  require_relative File.join('resources', 'embedelementaction')
  require_relative File.join('resources', 'embedmapaction')
  require_relative File.join('resources', 'linkelementaction')
  require_relative File.join('resources', 'removeelementaction')
end
