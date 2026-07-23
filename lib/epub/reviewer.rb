module UMPTG::EPUB

  require_relative 'pipeline'
  require_relative 'util'

  class Reviewer < Pipeline::Processor
    def initialize(name, processors: {}, filters: nil, options: {}, logger: nil)
      options = {
            css_font_face: false,
            epub_oebps_accessmode: true,
            epub_oebps_accessfeature: true,
            epub_oebps_access_hazard: true,
            epub_oebps_accessmode_sufficient: true,
            epub_oebps_access_summary: true,
            epub_oebps_conforms_to: false,
            epub_oebps_lang: true,
            epub_oebps_opf: false,
            epub_xhtml_lang: true,
            xhtml_entity: false,
            xhtml_extdescr: true,
            xhtml_figure: true,
            xhtml_header_title: false,
            xhtml_img_alttext: true,
            xhtml_pagebreak: true,
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

      entry_action = entry_actions.find {|ea| ea.entry.media_type == "application/oebps-package+xml" }
      raise "missing OEBPS entry" if entry_action.nil?

      metadata_node = entry_action.entry.document.xpath("//*[local-name()='metadata']").first
      raise "unable to locate OEBPS metadata node" if metadata_node.nil?

      run_options = options.clone
      run_options[:entry] = entry_action.entry
      run_options[:entry_actions] = entry_actions

      OEBPS::Pipeline::Filter::AccessModeFilter.review_issues(entry_action.issues, options: run_options)
      OEBPS::Pipeline::Filter::AccessModeSufficientFilter.review_issues(entry_action.issues, options: run_options)
      OEBPS::Pipeline::Filter::AccessHazardFilter.review_issues(entry_action.issues, options: run_options)
      OEBPS::Pipeline::Filter::AccessFeatureFilter.review_issues(entry_action.issues, options: run_options)
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
  end
end
