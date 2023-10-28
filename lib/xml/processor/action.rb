module UMPTG::XML::Processor
  require_relative(File.join("action", "action"))
  require_relative(File.join("action", "normalizeaction"))
  require_relative(File.join("action", "embedaction"))
  require_relative(File.join("action", "normalizeinsertmarkupaction"))
  require_relative(File.join("action", "removeattributeaction"))
  require_relative(File.join("action", "removeelementaction"))
  require_relative(File.join("action", "setattributevalueaction"))
  require_relative(File.join("action", "stripattributevalueaction"))
  require_relative(File.join("action", "processor"))
end
