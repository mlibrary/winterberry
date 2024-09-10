module UMPTG::Fulcrum

  require_relative(File.join("..", "..", "..", "lib", "xml", "pipeline"))

  require_relative(File.join("metadata", "actions"))
  require_relative(File.join("metadata", "filters"))
  require_relative(File.join("metadata", "processor"))
end
