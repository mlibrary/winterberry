module UMPTG::XHTML::Pipeline
  require_relative(File.join("actions", "markerobject"))
  require_relative(File.join("actions", "figureobject"))
  require_relative(File.join("actions", "action"))
  require_relative(File.join("actions", "figureaction"))
  require_relative(File.join("actions", "markeraction"))
  require_relative(File.join("actions", "imageaction"))
  require_relative(File.join("actions", "normalizefigureaction"))
  require_relative(File.join("actions", "normalizefigurecaptionstyleaction"))
  require_relative(File.join("actions", "normalizefigurecontaineraction"))
  require_relative(File.join("actions", "normalizefigurenestaction"))
  require_relative(File.join("actions", "normalizeimagecontaineraction"))
end
