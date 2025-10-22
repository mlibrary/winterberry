module UMPTG::EPUB

  require_relative 'pipeline'
  require_relative 'util'

  class Reviewer < Pipeline::Processor
    def initialize(args = {})
      a = args.clone
      a[:name] = "EPUBReviewProcessor"
      a[:options] = {
            epub_oebps_accessmode: true,
            epub_oebps_accessfeature: true,
            xhtml_extdescr: true,
            xhtml_figure: true,
            xhtml_img_alttext: true,
            xhtml_link: true,
            xhtml_table: true
          }
      super(a)
    end

    def process_entry_action_results(args = {})
      super(args)

      entry_actions = args[:entry_actions]
      llogger = args[:logger] || @logger

      # Figure links
      link_actions = []
      entry_actions.each {|ea| link_actions += ea.select_by_name(name: :xhtml_link) }

      figure_actions = []
      entry_actions.each {|ea| figure_actions += ea.select_by_name(name: :xhtml_figure) }

      unless figure_actions.count == 0
        linked_figures = []
        entry_actions.each do |ea|
          ea.select_by_name(name: :xhtml_figure).each do |ac|
            figure_id = ac.reference_node['id'] || ""
            unless figure_id.empty?
              href = File.basename(ea.entry.name) + "#" + figure_id
              ll = link_actions.find {|la| (la.reference_node['href'] || "").strip.end_with?(href) }
              linked_figures << ll.reference_node unless ll.nil?
            end
          end
        end
        llogger.info("#{name}, linked figures=#{linked_figures.count}")
      end
    end
  end
end
