module UMPTG::EPUB
  #require_relative(File.join("..", "object"))

  class EntryActions < UMPTG::Object
    attr_accessor :entry, :processor, :issues, :result

    def initialize(entry, processor: nil, issues: [], result: result)
      super(
              entry: entry,
              processor: processor,
              issues: issues,
              result: result
            )

      @entry = @properties[:entry]
      @processor = @properties[:processor]
      @issues = @properties[:issues]
      @result = @properties[:result]
    end

    def select(name:)
      actions = []
      @result.issues.each do |issue|
        next unless issue.name == name
        actions += issue.actions
      end
      return actions
    end
  end
end
