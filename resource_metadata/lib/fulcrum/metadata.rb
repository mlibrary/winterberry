module UMPTG::Fulcrum

  require_relative(File.join("..", "..", "..", "lib", "xml", "pipeline"))

  require_relative(File.join("metadata", "markerobject"))
  require_relative(File.join("metadata", "figureobject"))
  require_relative(File.join("metadata", "action"))
  require_relative(File.join("metadata", "figureaction"))
  require_relative(File.join("metadata", "markeraction"))
  require_relative(File.join("metadata", "resourcemetadatafilter"))
end
