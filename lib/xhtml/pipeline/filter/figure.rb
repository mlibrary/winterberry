module UMPTG::XHTML::Pipeline::Filter

  class Figure < UMPTG::Object
    attr_reader :container_node
    attr_accessor :img_list, :table_list, :caption_list

    def initialize(args = {})
      super(args)

      @container_node = @properties[:container_node]
      @img_list = @properties.key?(:img_list) ? @properties[:img_list] : []
      @table_list = @properties.key?(:table_list) ? @properties[:table_list] : []
      @caption_list = @properties.key?(:caption_list) ? @properties[:caption_list] : []
    end
  end
end
