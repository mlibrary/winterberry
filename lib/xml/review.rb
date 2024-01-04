module UMPTG::XML
  require_relative("pipeline")

  require_relative(File.join("review", "actions"))
  require_relative(File.join("review", "elementselector"))
  require_relative(File.join("review", "figure"))
  require_relative(File.join("review", "image"))
  require_relative(File.join("review", "filter"))
  require_relative(File.join("review", "processor"))
end
