module UMPTG::CSS::Pipeline

  class ReplaceStringAction < UMPTG::Pipeline::NormalizeAction

    def initialize(issue, options: {})
      super(issue, options: options)

      @match_data = options[:match_data]
      @replace_str = options[:replace_str]
    end

    def resolve(options: {})
      super(options: options)

      md = issue.content.content.match(@match_data.regexp)
      st = md.begin(@match_data.length-1) - 1
      nd = md.end(@match_data.length-1)

      issue.content.content = issue.content.content[0..st] + @replace_str + issue.content.content[nd..-1]
      add_info_msg("#{issue.name}, replaced \"#{md[md.length-1]}\" with \"#{@replace_str}\"")

      @status = UMPTG::Action.COMPLETED
    end
  end
end
