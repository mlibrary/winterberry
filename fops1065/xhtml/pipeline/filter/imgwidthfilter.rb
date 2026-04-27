module UMPTG::FOPS1065::XHTML::Pipeline::Filter

  class ImgWidthFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='img'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_img_width,
              XPATH,
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
        cl = issue.content['class'] || ""
        #unless cl.split(' ').include?("img-width")
        if cl.empty?
          issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                   name: issue.name,
                   reference_node: issue.content,
                   attribute_name: "class",
                   attribute_value: "img-width",
                   warning_message: \
                     "#{issue.name}, #{issue.content.name} no width class=\"#{issue.content['src']}\" class=\"#{issue.content['class']}\""
               )
        end
      end
    end
  end
end
