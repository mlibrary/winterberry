module UMPTG::XML::Review

  class Figure < UMPTG::Object
    attr_reader :container_node
    attr_accessor :img_list, :caption_list

    def initialize(args = {})
      super(args)

      @container_node = @properties[:container_node]
      @img_list = @properties.key?(:img_list) ? @properties[:img_list] : []
      @caption_list = @properties.key?(:caption_list) ? @properties[:caption_list] : []
    end
  end
end
