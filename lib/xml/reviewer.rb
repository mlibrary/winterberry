module UMPTG::XML
  require_relative("pipeline")

  require_relative(File.join("reviewer", "action"))
  require_relative(File.join("reviewer", "elementselector"))
  require_relative(File.join("reviewer", "figure"))
  require_relative(File.join("reviewer", "image"))
  require_relative(File.join("reviewer", "filter"))
  require_relative(File.join("reviewer", "processor"))
end
