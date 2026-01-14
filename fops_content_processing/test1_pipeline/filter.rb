module Test1Pipeline
  require_relative(File.join("..", "..", "lib", "pipeline", "filter"))

  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }

  FILTERS = {
        pipeline_string_length: StringLengthFilter,
        pipeline_dup_string: DupStringFilter
      }

  def self.FILTERS
    return FILTERS
  end
end
