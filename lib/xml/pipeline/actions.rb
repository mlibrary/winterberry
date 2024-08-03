module UMPTG::XML::Pipeline
  require_relative(File.join("actions", "normalizeaction"))
  require_relative(File.join("actions", "addnamespaceaction"))
  require_relative(File.join("actions", "embedaction"))
  require_relative(File.join("actions", "markupaction"))
  require_relative(File.join("actions", "normalizeinsertmarkupaction"))
  require_relative(File.join("actions", "removeattributeaction"))
  require_relative(File.join("actions", "removeelementaction"))
  require_relative(File.join("actions", "removenamespaceaction"))
  require_relative(File.join("actions", "setattributevalueaction"))
  require_relative(File.join("actions", "stripattributevalueaction"))
  require_relative(File.join("actions", "tablemarkupaction"))
end
