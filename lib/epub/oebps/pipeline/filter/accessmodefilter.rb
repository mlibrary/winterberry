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

    def initialize(args = {})
      a = args.clone
      a[:name] = :epub_oebps_accessmode
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <meta> element

      action_list = []

      case reference_node['property']
      when 'schema:accessMode', 'schema:accessModeSufficient'
        action_list << UMPTG::XML::Pipeline::Action.new(
               name: name,
               reference_node: reference_node,
               info_message: "#{name}, found #{reference_node}"
           )
      end
      return action_list
    end

    def process_action_results(args = {})
      super(args)

      action_results = args[:action_results]
      logger = args[:logger]

      # <meta property="schema:accessModeSufficient">textual</meta>
      textual_found = false
      actions.each do |a|
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
