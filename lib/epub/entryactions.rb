module UMPTG::EPUB
  #require_relative(File.join("..", "object"))

  class EntryActions < UMPTG::Object
    attr_accessor :result, :entry

    def initialize(entry, result)
      super(
              entry: entry,
              result: result
            )

      @result = @properties[:result]
      @entry = @properties[:entry]
    end

    def select_by_name(name)
      name = args[:name]

      actions = []
      @result.issues.each do |issue|
        next unless issue.name == name
        actions += issue.actions
      end
      return actions
    end
  end
end
