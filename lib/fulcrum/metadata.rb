module UMPTG::Fulcrum
  # Current implementation
  require_relative(File.join("..", "xml", "pipeline"))

  require_relative(File.join("metadata", "actions"))
  require_relative(File.join("metadata", "filters"))
  require_relative(File.join("metadata", "processor"))

  # Deprecated implementation
  require_relative File.join('..', 'fragment')

  require_relative File.join('metadata', 'figureobject')
  require_relative File.join('metadata', 'markerobject')
  require_relative File.join('metadata', 'action')
  require_relative File.join('metadata', 'figureaction')
  require_relative File.join('metadata', 'markeraction')
  require_relative File.join('metadata', 'processors')
end
