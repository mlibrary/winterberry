module UMPTG::EPUB

  require_relative 'pipeline'
  require_relative 'util'

  class Reviewer < Pipeline::Processor
    def initialize(name, processors: {}, filters: nil, options: {}, logger: nil)
      options = {
            css_a_decoration: false,
            css_font_face: false,
            css_access_display_transform: true,
            epub_oebps_accessmode: true,
            epub_oebps_accessfeature: true,
            epub_oebps_access_hazard: true,
            epub_oebps_accessmode_sufficient: true,
            epub_oebps_access_summary: true,
            epub_oebps_conforms_to: true,
            epub_oebps_lang: true,
            epub_oebps_opf: false,
            epub_oebps_pagebreaksource: true,
            epub_xhtml_lang: true,
            epub_xhtml_divisionrole: false,
            epub_xhtml_tocrole: false,
            xhtml_empty_header: false,
            xhtml_empty_link: false,
            xhtml_entity: false,
            xhtml_extdescr: true,
            xhtml_figure: true,
            xhtml_header_level: false,
            xhtml_header_title: false,
            xhtml_img_alttext: true,
            xhtml_pagebreak: false,
            xhtml_link: true,
            xhtml_table_overflow: false,
            xhtml_table_pagebreak: false,
            xhtml_table_tbody: true,
            xhtml_list_item: false
          }
      super(
            name,
            processors: processors,
            options: options,
            logger: logger
          )
    end

    def review(entry_actions, options: {}, logger: nil)
      super(
           entry_actions,
           options: options,
           logger: logger
         )

      UMPTG::EPUB::OEBPS::Pipeline.review_issues(entry_actions, options: options, logger: logger)
      UMPTG::EPUB::Reviewer.review_pagebreak_issues(entry_actions, options: options, logger: logger)
    end

    def report(entry_results, options: {}, logger: nil)
      super(
          entry_results,
          options: options,
          logger: logger
        )

      llogger = logger || @logger

      # Figure links
      link_actions = []
      entry_results.each {|ea| link_actions += ea.select(name: :xhtml_link) }

      figure_actions = []
      entry_results.each {|ea| figure_actions += ea.select(name: :xhtml_figure) }

      unless figure_actions.count == 0
        linked_figures = []
        entry_results.each do |ea|
          ea.select(name: :xhtml_figure).each do |ac|
            next unless ac.class.name == "UMPTG::XML::Pipeline::Action"

            figure_id = ac.issue.content['id'] || ""
            unless figure_id.empty?
              href = File.basename(ea.entry.name) + "#" + figure_id
              ll = link_actions.find {|la| (la.issue.content['href'] || "").strip.end_with?(href) }
              linked_figures << ll.issue.content unless ll.nil?
            end
          end
        end
        llogger.info("#{name}, linked figures=#{linked_figures.count}")
      end
    end

    def self.review_pagebreak_issues(entry_actions, options: options, logger: logger)
      pagebreak_issues = []
      css_entry_action = nil
      entry_actions.each do |ea|
        css_entry_action = ea if ea.entry.media_type == "text/css"
        pagebreak_issues += ea.issues.select {|i| i.name == :xhtml_pagebreak }
      end

      if pagebreak_issues.count > 0
        raise "missing CSS entry" if css_entry_action.nil?

        pagebreak_issues.each do |issue|
          issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
              issue,
              options: {
                      attribute_name: "class",
                      attribute_value: "umptg_page",
                      attribute_append: true,
                      warning_message: "#{@name}, found invalid pagebreak class attribute #{issue.content}"
                  }
            )
        end

        issue = UMPTG::Issue.new(
                  name: :xhtml_pagebreak,
                  content: css_entry_action.entry.document
                )
        css_entry_action.issues << issue

        issue.actions << UMPTG::CSS::Pipeline::AddClassAction.new(
                issue,
                options: {
                      add_content: ".umptg_page { font-style: inherit; font-size: 80%; color: #666666; text-decoration: none; }",
                      warning_message: "#{@name}, missing CSS class \".page\""
                    }
              )
      end
    end
  end
end
