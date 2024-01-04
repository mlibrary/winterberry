module UMPTG::XML
  require_relative(File.join("..", "object"))
  require_relative(File.join("..", "action"))
  require_relative(File.join("..", "logger"))

  require_relative(File.join("pipeline", "action"))
  require_relative(File.join("pipeline", "actions"))
  require_relative(File.join("pipeline", "actionresult"))
  require_relative(File.join("pipeline", "filter"))
  require_relative(File.join("pipeline", "processor"))
end
