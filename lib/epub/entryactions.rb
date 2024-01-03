module UMPTG::EPUB
  require_relative(File.join("..", "object"))

  class EntryActions < UMPTG::Object
    attr_accessor :action_result, :entry

    def initialize(args = {})
      super(args)

      @action_result = @properties[:action_result]
      @entry = @properties[:entry]
    end
  end
end
