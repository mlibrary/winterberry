module UMPTG::XML::Reviewer

  class Image < UMPTG::Object
    attr_reader :container_node, :img_node, :within_caption

    def initialize(args = {})
      super(args)

      @container_node = @properties[:container_node]
      @img_node = @properties[:img_node]
      @within_caption = @properties.key?(:within_caption) ? @properties[:within_caption] : false
    end
  end
end
