module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessModeFilter < UMPTG::XML::Pipeline::Filter
  # <meta property="schema:accessModeSufficient">textual</meta>

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    ]/*[
    local-name()='meta' and (
    @property='schema:accessModeSufficient' or (
    @property='schema:accessMode' and translate(normalize-space(text()),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='textual'
    )
    )
    ]
    SXPATH

    def initialize(options: nil)
      super(
              name: :epub_oebps_accessmode,
              xpath: XPATH,
              options: options
            )
    end

    def resolve(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      name = issue.name
      reference_node = issue.content  # <meta> element

      case reference_node['property']
      when 'schema:accessMode', 'schema:accessModeSufficient'
        issue.actions << UMPTG::XML::Pipeline::Action.new(
               name: name,
               reference_node: reference_node,
               info_message: "#{name}, found #{reference_node}"
           )
      end
    end

    def report(issues, logger:, options: {})
      super(issues, logger: logger, options: options)

      actions = []
      issues.each {|i| actions += i.actions }

      # <meta property="schema:accessModeSufficient">textual</meta>
      textual_found = false
      actions.each do |a|
        next unless a.class == "UMPTG::XML::Pipeline::Action"

        if ['schema:accessMode', 'schema:accessModeSufficient'].include?(a.reference_node['property'])
          content = (a.reference_node.content || "").strip
          if content.split(',').select {|s| s.strip.downcase == "textual"}.count > 0
            textual_found = true
            break
          end
        end
      end

      if textual_found
        logger.info("#{name} accessModeSufficient=textual found")
      else
        logger.warn("#{name}, accessModeSufficient=textual not found")
      end
    end
  end
end
