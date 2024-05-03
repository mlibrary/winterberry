module UMPTG
  require_relative('logger')
  require_relative('message')
  require_relative('services')

  require_relative File.join('fulcrum', 'manifest')
  require_relative File.join('fulcrum', 'resourcemap')
  require_relative File.join('journal', 'jatsrenderer')
  require_relative File.join('journal', 'jatsresourceprocessor')

  require_relative File.join('xml', 'pipeline')
  require_relative File.join('journal', 'jats')
  require_relative File.join('journal', 'resource')
end
