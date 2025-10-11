module UMPTG::XHTML::Pipeline
  require_relative(File.join("filter", "imgalttextfilter"))
  require_relative(File.join("filter", "extdescrfilter"))
  require_relative(File.join("filter", "migrationfilter"))

  FILTERS = {
        xhtml_img_alttext: UMPTG::XHTML::Pipeline::Filter::ImgAltTextFilter,
        xhtml_extdescr: UMPTG::XHTML::Pipeline::Filter::ExtDescrFilter,
        xhtml_migration: UMPTG::XHTML::Pipeline::Filter::MigrationFilter
      }

  def self.ImgAltTextFilter(args = {})
    return FILTERS[:xhtml_img_alttext].new(args)
  end

  def self.ExtDescrFilter(args = {})
    return FILTERS[:xhtml_extdescr].new(args)
  end

  def self.MigrationFilter(args = {})
    return FILTERS[:xhtml_migration].new(args)
  end

  def self.FILTERS
    return FILTERS
  end
end
