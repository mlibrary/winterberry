module UMPTG::CSS::Pipeline

  class AccessDisplayTransformFilter < UMPTG::Pipeline::Filter

    REG_EXP_LIST = [
          #Regexp.new(/([a-zA-Z0-9\-\.]+[\s]*\{[\s]*([0-9]+(px|pt));)/),
          Regexp.new(/([a-zA-Z0-9\-\.]+[\s]*\{[a-zA-Z0-9\.\-:;\s]*([0-9]+[\s]*(px|pt))[\s]*;[a-zA-Z0-9\.\-:;\s]*\})/),
          #Regexp.new(/([a-zA-Z0-9\-\s]*:[\s]*[0-9]+[\s]*(px|pt)[\s]*;)/),
          #Regexp.new(/(([0-9]+(px|pt)))/),
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
              :css_access_display_transform,
              options: options
            )
    end

    def select(content, options: {})
      issues = []
      c = content.content
      REG_EXP_LIST.each do |regex|
        while !c.empty?
          md = c.match(regex)
          break if md.nil?
          con = Content.new(content, md)
          issues << UMPTG::Issue.new(name: name, content: con)
          c = c[md.end(0)..-1]
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

      issue.actions << UMPTG::XML::Pipeline::Action.new(
              issue,
              options: {
                  warning_message: \
                    "#{issue.name}, found CSS fixed display \"#{match_data[0].strip}\""
                  }
          )
=begin
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
=end
    end

=begin
    def resolve(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      name = issue.name

      issue.content.match(/^body[ ]+\{/) do |md|
        issue.actions << UMPTG::CSS::Pipeline::FontFixAction.new(
                name: a[:name],
                content: issue.content,
                match_data: md,
                info_message: "#{a[:name]}, found #{md[0]}"
              )
      end
#=begin
      issue.content.match(/font-family:[^;]+/) do |md|
        issue.actions << UMPTG::XML::Pipeline::Action.new(
                  name: a[:name],
                  info_message: "#{a[:name]}, found #{md[0]}"
              )
      end
#=end
    end
=end
  end
end
