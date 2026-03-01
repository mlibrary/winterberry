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

    def review(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      name = issue.name

      case issue.content['property']
      when 'schema:accessMode', 'schema:accessModeSufficient'
        issue.actions << UMPTG::XML::Pipeline::Action.new(
               name: issue.name,
               reference_node: issue.content,
               info_message: "#{issue.name}, found #{issue.content}"
           )
      end
    end

    def self.review(issues, options: {})
      actions = []
      issues.each {|i| actions += i.actions }

      # <meta property="schema:accessModeSufficient">textual</meta>
      acs_textual_actions = []
      actions.each do |a|
        next unless a.class.name == "UMPTG::XML::Pipeline::Action"

        if ['schema:accessMode', 'schema:accessModeSufficient'].include?(a.reference_node['property'])
          content = (a.reference_node.content || "").strip
          if content.split(',').select {|s| s.strip.downcase == "textual"}.count > 0
            acs_textual_actions << a
          end
        end
      end

      issue = UMPTG::Issue.new(name: :epub_oebps_accessmode, content: issues.first.content.parent)
      issues << issue

      act = UMPTG::Pipeline::Action.new(issue.name, options: options)
      issue.actions << act

      case acs_textual_actions.count
      when 0
        act.add_warning_msg("#{issue.name}, accessModeSufficient=textual not found")
      when 1
        act.add_info_msg("#{issue.name} accessModeSufficient=textual found")
      else
        act.add_warning_msg("#{issue.name} duplicate markup #{acs_textual_actions.last.reference_node}")
      end
    end
  end
end
