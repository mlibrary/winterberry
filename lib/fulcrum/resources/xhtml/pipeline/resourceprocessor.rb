module UMPTG::Fulcrum::Resources::XHTML::Pipeline

  class ResourceProcessor < UMPTG::XHTML::Pipeline::Processor

    CSS_XPATH = <<-SXPATH
    /*[
    local-name()='html'
    ]/*[
    local-name()='head'
    ]/*[
    local-name()='link'
    ][
    last()
    ]
    SXPATH

    def initialize(name, manifest, filters: nil, options: {}, logger: nil)
      m_filters = filters.nil? ? UMPTG::Fulcrum::Resources::XHTML::Pipeline.FILTERS : \
                  filters.merge(UMPTG::Fulcrum::Resources::XHTML::Pipeline.FILTERS)
      @manifest = manifest

      super(
            name,
            filters: m_filters,
            options: options,
            logger: logger
          )
    end

    def create_filter(class_name, options: {})
      return class_name.new(
                  @manifest,
                  options: options
                )
    end

    def review(issues, options: {})
      super(
            issues,
            options: options
          )

      actions = []
      issues.each {|issue| actions += issue.actions }

      unless actions.empty?
        modified = false
        actions.each do |a|
          if a.normalize and a.status == UMPTG::Action.COMPLETED
            modified = true
            break
          end
        end
        if modified
          reference_node = issues.last.content.document.xpath(CSS_XPATH).first
          raise "unable to add Fulcrum CSS stylesheet" if reference_node.nil?

          a = {
              reference_node: reference_node,
              markup: '<link href="../styles/fulcrum_default.css" rel="stylesheet" type="text/css"/>',
              info_message: "Fulcrum CSS stylesheet must be added"
            }
          issues.last.actions << UMPTG::XML::Pipeline::Actions::NormalizeInsertMarkupAction.new(a)
        end
      end
    end
  end
end
