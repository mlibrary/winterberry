module UMPTG::Pipeline
  require_relative File.join('actions', 'normalizeaction')

  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "actions", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }
end
