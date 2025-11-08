module UMPTG::CSS::Pipeline

  class FontFixAction < UMPTG::XML::Pipeline::Actions::NormalizeAction
    attr_reader :name, :content

    def initialize(args = {})
      super(args)

      @name = @properties[:name]
      @content = @properties[:content]
      @match_data = @properties[:match_data]
    end

    def process(args = {})
      super(args)

      @content.sub!(@match_data[0], 'body, div, p {')
      add_info_msg("#{@name},replaced \"#{@match_data[0]}\" with \"body, div, p {\"")
      @status = UMPTG::XML::Pipeline::Action.COMPLETED

=begin
      c = @content.gsub(/\/times/, 'times')
      if c != @content
        @content = c

        add_info_msg("#{@name},replace \"/times\" with \"times\"")
        @status = UMPTG::XML::Pipeline::Action.COMPLETED
      else
        @status = UMPTG::XML::Pipeline::Action.NO_ACTION
      end
=end
    end
  end
end
