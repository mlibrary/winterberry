module UMPTG::XML
  require_relative(File.join("..", "object"))
  require_relative(File.join("..", "action"))
  require_relative(File.join("..", "logger"))

  require_relative(File.join("processor", "action"))
  require_relative(File.join("processor", "actionresult"))
  require_relative(File.join("processor", "filter"))
  require_relative(File.join("processor", "processor"))
end
