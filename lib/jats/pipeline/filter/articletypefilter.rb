module UMPTG::JATS::Pipeline::Filter

  class ArticleTypeFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='article'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :jats_article_type,
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

      if issue.content.name == 'article'
        article_type = issue.content['article-type']
        issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                  name: issue.name,
                  reference_node: issue.content,
                  attribute_name: "article-type",
                  attribute_value: "Articles",
                  warning_message: "#{issue.name}, #{issue.content.name} @article-type=\"#{article_type}\""
                )
      end
    end
  end
end
