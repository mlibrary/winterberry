module UMPTG::Fulcrum
  # Current implementation
  require_relative(File.join("..", "xml", "pipeline"))
  require_relative(File.join("..", "services"))

  require_relative File.join('metadata', 'xhtml')
  require_relative File.join('metadata', 'epubprocessor')
end
