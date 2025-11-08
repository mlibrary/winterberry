module UMPTG::CSS::Pipeline

  class FontFamilyAction < UMPTG::XML::Pipeline::Actions::NormalizeAction
    attr_reader :name, :content

    def initialize(args = {})
      super(args)

      @name = @properties[:name]
      @content = @properties[:content]
    end

    def process(args = {})
      super(args)

      updated = false
      new_lines = []
      @content.lines.each do |ln|
        md = ln.match(/font-family:[^;]*/)
        if md.nil? or ln.include?("TimesNewRoman")
          new_lines << ln
          next
        end
        add_info_msg("#{@name}, removed \"#{md[0]}\"")
        updated = true
      end
      if updated
        @content = new_lines.join
        @status = UMPTG::XML::Pipeline::Action.COMPLETED
      else
        @status = UMPTG::XML::Pipeline::Action.NO_ACTION
      end
    end
  end
end
