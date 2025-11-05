module UMPTG::CSS::Pipeline

  class TimesFontAction < UMPTG::XML::Pipeline::Actions::NormalizeAction
    attr_reader :name, :content, :font_faces

    def initialize(args = {})
      super(args)

      @name = @properties[:name]
      @content = @properties[:content]
      @font_faces = []
    end

    def process(args = {})
      super(args)
      add_info_msg("#{@name}")

      content_lines = @content.lines

      # Remove @font-face classes
      new_lines = []
      @font_faces = []
      in_font_face = false
      content_lines.each do |n|
        next if n.match(/\/\*[ \-]+Fonts[ \-]+\*\//)

        case
        when in_font_face
          n.match(/src[ ]*:[^"]+"([^"]+)"/) {|md| @font_faces << md[1] }

          in_font_face = false if n.match(/\}/)
        when n.match(/\@font-face[ ]+\{/)
          in_font_face = true
        else
          new_lines << n
        end
      end
      @font_faces.uniq!

      # Remove font-family Times from all classes
      new_lines.delete_if {|n| n.match(/font-family:[ ]*"Times New Roman"/) }

      # Insert body/font-family value
      new_lines.insert(1, "body {\n\tfont-family: TimesNewRoman,Times New Roman,Times,Baskerville,Georgia,serif;\n}\n\n")

      if new_lines.count != @content.lines.count
        # Content changed, update and report.
        @content = new_lines.join

        add_info_msg("#{@name}, remove fonts")
        @status = UMPTG::XML::Pipeline::Action.COMPLETED
      else
        # Content unchanged, report.
        add_warning_msg("#{@name}, remove fonts failed")
        @status = UMPTG::XML::Pipeline::Action.NO_ACTION
      end
    end

    def self.process_actions(args = {})
      actions = args.key?(:actions) ? args[:actions] : []
      normalize = args[:normalize] || false
      display_msgs = args[:display_msgs] || true

      modified = false
      if normalize
        actions.each do |a|
          a.process(args)
          modified = true if a.normalize and a.status == UMPTG::Action.COMPLETED
        end
      end
      if display_msgs
        UMPTG::XML::Pipeline::Action.display_messages(
              actions: actions,
              logger: args[:logger]
           )
      end

      return UMPTG::XML::Pipeline::ActionResult.new(
              actions: actions,
              modified: modified
              )
    end

    def self.display_messages(args = {})
      logger = args[:logger]
      return if logger.nil?

      actions = args.key?(:actions) ? args[:actions] : []
      #logger = args.key?(:logger) ? args[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)

      actions.each do |action|
        action.messages.each do |msg|
          case msg.level
          when UMPTG::Message.INFO
            logger.info(msg.text)
          when UMPTG::Message.WARNING
            logger.warn(msg.text)
          when UMPTG::Message.ERROR
            logger.error(msg.text)
          when UMPTG::Message.FATAL
            logger.fatal(msg.text)
          end
        end
      end
    end

    def self.report_actions(args = {})
      raise "deprecated"
    end
  end
end
