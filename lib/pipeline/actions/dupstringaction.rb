module UMPTG::Pipeline

  class DupStringAction < UMPTG::Pipeline::NormalizeAction

    attr_reader :normalize

    def process(options: nil)
      super(
            options: options
          )
      @issue.content += @issue.content
      add_info_msg("#{@issue.name}, duplicated content \"#{@issue.content}\"")
      @status = UMPTG::Action.COMPLETED
    end
  end
end
