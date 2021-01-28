module UMPTG::FMetadata
  class Action < UMPTG::Action
    attr_reader :fragment
    attr_accessor :object_list

    def initialize(args = {})
      super(args)
      @fragment = args[:fragment]
      @object_list = args.key?(:object_list) ? args[:object_list] : []
    end
  end
end
