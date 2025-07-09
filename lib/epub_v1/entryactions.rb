module UMPTG::EPUB
  require_relative(File.join("..", "object"))

  class EntryActions < UMPTG::Object
    attr_accessor :action_result, :entry

    def initialize(args = {})
      super(args)

      @action_result = @properties[:action_result]
      @entry = @properties[:entry]
    end

    def select_by_name(args = {})
      name = args[:name]

      return action_result.actions.select {|a| a.name == name }
    end
  end
end
