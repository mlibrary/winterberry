module UMPTG::XHTML::Pipeline
  require_relative(File.join("filter", "imgalttextfilter"))
  require_relative(File.join("filter", "extdescrfilter"))
  require_relative(File.join("filter", "figurefilter"))
  require_relative(File.join("filter", "headertitlefilter"))
  require_relative(File.join("filter", "linkfilter"))
  require_relative(File.join("filter", "migrationfilter"))
  require_relative(File.join("filter", "tablefilter"))

  FILTERS = {
        xhtml_img_alttext: UMPTG::XHTML::Pipeline::Filter::ImgAltTextFilter,
        xhtml_extdescr: UMPTG::XHTML::Pipeline::Filter::ExtDescrFilter,
        xhtml_figure: UMPTG::XHTML::Pipeline::Filter::FigureFilter,
        xhtml_header_title: UMPTG::XHTML::Pipeline::Filter::HeaderTitleFilter,
        xhtml_link: UMPTG::XHTML::Pipeline::Filter::LinkFilter,
        xhtml_migration: UMPTG::XHTML::Pipeline::Filter::MigrationFilter,
        xhtml_table: UMPTG::XHTML::Pipeline::Filter::TableFilter
      }

  def self.ImgAltTextFilter(args = {})
    return FILTERS[:xhtml_img_alttext].new(args)
  end

  def self.ExtDescrFilter(args = {})
    return FILTERS[:xhtml_extdescr].new(args)
  end

  def self.HeaderTitleFilter(args = {})
    return FILTERS[:xhtml_figure].new(args)
  end

  def self.FigureFilter(args = {})
    return FILTERS[:xhtml_figure].new(args)
  end

  def self.LinkFilter(args = {})
    return FILTERS[:xhtml_link].new(args)
  end

  def self.MigrationFilter(args = {})
    return FILTERS[:xhtml_migration].new(args)
  end

  def self.TableFilter(args = {})
    return FILTERS[:xhtml_table].new(args)
  end

  def self.FILTERS
    return FILTERS
  end
end
