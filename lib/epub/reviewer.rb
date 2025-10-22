module UMPTG::EPUB

  require_relative 'pipeline'
  require_relative 'util'

  class Reviewer < Pipeline::Processor
    def initialize(args = {})
      a = args.clone
      a[:options] = {
            epub_oebps_accessmode: true,
            epub_oebps_accessfeature: true,
            xhtml_extdescr: true,
            xhtml_img_alttext: true,
            xhtml_table: true
          }
      super(a)
    end

    def process_entry_action_results(args = {})
      super(args)
    end
  end
end
