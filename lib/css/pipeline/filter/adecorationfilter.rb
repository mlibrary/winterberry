module UMPTG::CSS::Pipeline

  class ADecorationFilter < UMPTG::Pipeline::Filter

    REG_EXP_LIST = [
          #Regexp.new(/(a[\s]*\{[\s]+text-decoration[\s]*:[\s]*(none)[\s]*;)/),
          Regexp.new(/(.www[\s]+\{[\s]+text-decoration[\s]*:[\s]*(none)[\s]*;)/),
          Regexp.new(/(.nounder[\s]+\{[\s]+text-decoration[\s]*:[\s]*(none)[\s]*;)/),
          Regexp.new(/(a\.pubhlink[\s]+\{[\s]+text-decoration[\s]*:[\s]*(none)[\s]*;)/),
          Regexp.new(/(a\.hlink[\s]+\{[\s]+text-decoration[\s]*:[\s]*(none)[\s]*;)/),
          Regexp.new(/(a[\s]*\{[a-zA-Z0-9\.\-:;\s]*text-decoration[\s]*:[\s]*(none)[\s]*;)/),
          Regexp.new(/(.author[\s]+\{[a-zA-Z0-9\.\-:;\s]*(color[\s]*:[^;]+;))/),
          Regexp.new(/(.h2b[\s]+\{[a-zA-Z0-9\.\-:;\s]*(color[\s]*:[^;]+;))/),
          Regexp.new(/(.h2_b[\s]+\{[a-zA-Z0-9\.\-:;\s]*(color[\s]*:[^;]+;))/),
          Regexp.new(/(.h3[\s]+\{[a-zA-Z0-9\.\-:;\s]*(color[\s]*:[^;]+;))/),
          Regexp.new(/(.center[\s]+\{[a-zA-Z0-9\.\-:;\s]*(color[\s]*:[^;]+;))/),
          Regexp.new(/(.bmcenter[\s]+\{[a-zA-Z0-9\.\-:;\s]*(color[\s]*:[^;]+;))/),
          Regexp.new(/(.bmcenter1[\s]+\{[a-zA-Z0-9\.\-:;\s]*(color[\s]*:[^;]+;))/),
          Regexp.new(/(.color[\s]+\{[a-zA-Z0-9\.\-:;\s]*(color[\s]*:[^;]+;))/),
        ]

    class Content
      attr_reader :content, :match_data

      def initialize(c, md)
        @content = c
        @match_data = md
      end
    end

    def initialize(process, options: {})
      super(
              process,
              :css_a_decoration,
              options: options
            )
    end

    def select(content, options: {})
      issues = []
      REG_EXP_LIST.each do |regex|
        offset = 0
        content.content.match(regex, offset) do |md|
          con = Content.new(content, md)
          issues << UMPTG::Issue.new(name: name, content: con)

          offset = md.end(0)
          #raise "CSS loop" if offset >= content.content.length
        end
      end
      return issues
    end

    def review(issue, options: {})
      match_data = issue.content.match_data
      issue.content = issue.content.content

      super(
            issue,
            options: options
          )

      case
      when match_data[match_data.length-1] == "none"
        replace_str = "underline"
      else
        replace_str = ""
      end

      act = UMPTG::CSS::Pipeline::ReplaceStringAction.new(
                  issue,
                  options: {
                        match_data: match_data,
                        replace_str: replace_str
                      }
               )
      act.add_info_msg("#{@name}, found issue #{issue.name} match=#{match_data[0]}")
      issue.actions << act
    end
  end
end
