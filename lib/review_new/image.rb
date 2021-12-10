module UMPTG::Review

  class Image < UMPTG::Object
    attr_reader :container_node, :img_node

    def initialize(args = {})
      super(args)

      @container_node = @properties[:container_node]
      @img_node = @properties[:img_node]
    end
  end
end
