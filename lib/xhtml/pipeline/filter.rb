module UMPTG::XHTML::Pipeline
  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }

  FILTERS = {
        xhtml_img_alttext: UMPTG::XHTML::Pipeline::Filter::ImgAltTextFilter,
        xhtml_entity: UMPTG::XHTML::Pipeline::Filter::EntityFilter,
        xhtml_extdescr: UMPTG::XHTML::Pipeline::Filter::ExtDescrFilter,
        xhtml_figure: UMPTG::XHTML::Pipeline::Filter::FigureFilter,
        xhtml_header_title: UMPTG::XHTML::Pipeline::Filter::HeaderTitleFilter,
        xhtml_link: UMPTG::XHTML::Pipeline::Filter::LinkFilter,
        xhtml_list_item: UMPTG::XHTML::Pipeline::Filter::ListItemFilter,
        xhtml_migration: UMPTG::XHTML::Pipeline::Filter::MigrationFilter,
        xhtml_noteref: UMPTG::XHTML::Pipeline::Filter::NoterefFilter,
        xhtml_page_translation: UMPTG::XHTML::Pipeline::Filter::PageTranslationFilter,
        xhtml_spine_item: UMPTG::XHTML::Pipeline::Filter::SpineItemFilter,
        xhtml_table: UMPTG::XHTML::Pipeline::Filter::TableFilter
      }

  def self.FILTERS
    return FILTERS
  end
end
