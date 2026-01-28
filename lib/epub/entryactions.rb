module UMPTG::EPUB
  #require_relative(File.join("..", "object"))

  class EntryActions < UMPTG::Object
    attr_accessor :action_result, :entry

    def initialize(args = {})
      super(args)

      @action_result = @properties[:action_result]
      @entry = @properties[:entry]
    end

    def select_by_name(args = {})
      name = args[:name]

      actions = []
      action_result.issues.each do |issue|
        next unless issue.name == name
        actions += issue.actions
      end
      return actions
    end
  end
end
