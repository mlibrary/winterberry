module UMPTG::EPUB

  require_relative 'pipeline'
  require_relative 'util'

  class Reviewer < Pipeline::Processor
    def initialize(name, processors: {}, filters: nil, options: {}, logger: nil)
      options = {
            css_font_face: false,
            epub_oebps_accessmode: true,
            epub_oebps_accessfeature: true,
            xhtml_entity: false,
            xhtml_extdescr: true,
            xhtml_figure: true,
            xhtml_header_title: false,
            xhtml_img_alttext: true,
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
