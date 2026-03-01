module UMPTG::XHTML::Pipeline::Filter

  class ImgAltTextFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='img'
    ]
    SXPATH

    def initialize(options: nil)
      super(
              name: :xhtml_img_alttext,
              xpath: XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      if issue.content.name == 'img'
        role = (issue.content["role"] || "").strip.downcase
        unless role == "presentation"
          alt = (issue.content["alt"] || "").strip
          if alt.empty?
              issue.actions << UMPTG::XML::Pipeline::Action.new(
                       name: issue.name,
                       reference_node: issue.content,
                       warning_message: \
                         "#{issue.name}, #{issue.content.name} no alt text src=\"#{issue.content['src']}\" role=\"#{issue.content['role']}\""
                   )
=begin
              issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                       name: name,
                       reference_node: reference_node,
                       attribute_name: "role",
                       attribute_value: "presentation",
                       warning_message: \
                         "#{name}, #{reference_node.name} no alt text src=\"#{reference_node['src']}\" role=\"#{reference_node['role']}\""
                   )
=end
          else
            issue.actions << UMPTG::XML::Pipeline::Action.new(
                     name: issue.name,
                     reference_node: issue.content,
                     info_message: \
                       "#{issue.name}, found #{issue.content}"
                 )
          end
        end
      end
    end

    def report(issues, options: {}, logger:)
      super(issues, options: options, logger: logger)

      cnt = 0
      issues.each do |issue|
        issue.actions.each {|a| a.messages.each {|m| cnt += 1 if m.level == UMPTG::Message.WARNING } }
      end

      act_text_msg = "#{name}, non-presentation images without alt text=#{cnt}"
      logger.info(act_text_msg) if cnt == 0
      logger.warn(act_text_msg) unless cnt == 0
    end
  end
end
