module UMPTG::EPUB

  require_relative 'pipeline'
  require_relative 'util'

  class TimesFontProcessor < Pipeline::Processor
    def initialize(args = {})
      a = args.clone
      a[:name] = "EPUBTimesFontProcessor"
      a[:options] = {
            css_times_font: true,
            css_font_face: false
          }
      super(a)
    end

    def process_entry_action_results(args = {})
      super(args)

      epub = args[:epub]
      entry_actions = args[:entry_actions]
      llogger = args[:logger] || @logger

      # CSS actions
      css_actions = []
      entry_actions.each {|ea| css_actions += ea.select_by_name(name: :css_times_font) }

      # Remove any font faces
      font_entries = epub.rendition.manifest.entries(entry_mediatype: "font/truetype")
      css_actions.each do |act|
        e_list = font_entries.select {|e| act.font_faces.include?(File.basename(e.name)) }
        e_list.each do |e|
          epub.rendition.manifest.remove(entry_name: e.name)
          llogger.info("removed entry #{e.name}")
        end
      end
=begin
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
=end
    end
  end
end
