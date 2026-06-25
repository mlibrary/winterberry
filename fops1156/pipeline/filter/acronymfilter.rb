module UMPTG::XHTML::Pipeline::Filter

  class AcronymFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='abbr'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_acronym,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(
              issue,
              options: options
           )

      if issue.content.name == 'abbr'
        msg = "#{issue.name}, #{issue.content.name} found #{issue.content.content}"

        case issue.content.content
        when "WASPS"
          action = UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                 issue,
                 options: {
                      action: :replace_content,
                      markup: "WASPs",
                      warning_message: msg
                    }
              )
        else
          action = UMPTG::XML::Pipeline::Action.new(
                  issue,
                  options: {
                      info_message: msg
                    }
              )
        end
        issue.actions << action
      end
    end

    def report(issues, options: {}, logger: nil)
      super(
              issues,
              options: options,
              logger: logger
           )

      content = {}
      issues.each do |issue|
        content[issue.content.content] += 1 if content.key?(issue.content.content)
        content[issue.content.content] = 1 unless content.key?(issue.content.content)
      end
      #logger.info("#{@name}, #{content.keys.join(',')}")
      content.each do |k,v|
        logger.info("#{@name}, #{k}=#{v}")
      end
    end
  end
end
