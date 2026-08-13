module UMPTG::XHTML::Pipeline::Filter

  class ImgAltTextFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='img'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_img_alttext,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(
              issue,
              options: options
           )

      if issue.content.name == 'img'
        role = (issue.content["role"] || "").strip.downcase
        if role == "presentation"
          issue.actions << UMPTG::XML::Pipeline::Action.new(
                   issue,
                   options: {
                       info_message: \
                         "#{issue.name}, #{issue.content.name} presentation image found src=\"#{issue.content['src']}\" role=\"#{issue.content['role']}\" alt=\"#{issue.content['alt']}\""
                       }
               )
        else
          src = (issue.content["src"] || "").strip
          alt = (issue.content["alt"] || "").strip
          #is_suspect = ["cover","image","images","","alt",File.basename(src).downcase,File.basename(src,".*").downcase].include?(alt.downcase)
          is_suspect = ["image1", "inline", "cover","image","images","","alt",File.basename(src).downcase,File.basename(src,".*").downcase].include?(alt.downcase)
          #is_suspect = true
          #puts "is_suspect=#{is_suspect},alt=#{alt}"
          if is_suspect
            #set_as_presentation = false
            role_value = "presentation"
            case alt.downcase
            when "cover"
              role_value = "presentation"
            when "image", "inline"
              role_value = "presentation"
            end
            if !role_value.empty?
              issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                       issue,
                       options: {
                           attribute_name: "role",
                           attribute_value: role_value,
                           warning_message: \
                             "#{name}, #{issue.content.name} no alt text src=\"#{issue.content['src']}\" role=\"#{issue.content['role']}\""
                           }
                   )
              issue.actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                       issue,
                       options: {
                           attribute_name: "alt",
                           warning_message: \
                             "#{name}, #{issue.content.name} invalid alt text src=\"#{issue.content['src']}\" alt=\"#{issue.content['alt']}\""
                           }
                   )
            else
              issue.actions << UMPTG::XML::Pipeline::Action.new(
                       issue,
                       options: {
                           warning_message: \
                             "#{issue.name}, #{issue.content.name} image with possible invalid alt text src=\"#{issue.content['src']}\" role=\"#{issue.content['role']}\" alt=\"#{issue.content['alt']}\""
                           }
                   )
            end
          else
            issue.actions << UMPTG::XML::Pipeline::Action.new(
                     issue,
                     options: {
                         info_message: \
                           "#{issue.name}, found #{issue.content}"
                         }
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
