module UMPTG::Fulcrum::Resources
  require_relative(File.join("filter", "embedlinkfilter"))
  require_relative(File.join("filter", "extdescrfilter"))
  require_relative(File.join("filter", "fulcrumcssfilter"))
  require_relative(File.join("filter", "removefigcaptionfilter"))
  require_relative(File.join("filter", "resourcereferencefilter"))
  require_relative(File.join("filter", "updatealttextfilter"))
  require_relative(File.join("filter", "updatehreffilter"))

  FILTERS = {
      embed_link: Filter::EmbedLinkFilter,
      ext_descr: Filter::ExtDescrFilter,
      fulcrum_css: Filter::FulcrumCSSFilter,
      remove_figcaption: Filter::RemoveFigcaptionFilter,
      resource_reference: Filter::ResourceReferenceFilter,
      update_alt: Filter::UpdateAltTextFilter,
      update_href: Filter::UpdateHREFFilter
    }

  def self.EmbedLinkFilter(args = {})
    return FILTERS[:embed_link].new(args)
  end

  def self.ExtDescrFilter(args = {})
    return FILTERS[:ext_descr].new(args)
  end

  def self.FulcrumCSSFilter(args = {})
    return FILTERS[:fulcrum_css].new(args)
  end

  def self.RemoveFigCaptionFilter(args = {})
    return FILTERS[:remove_figcaption].new(args)
  end

  def self.ResourceReferenceFilter(args = {})
    return FILTERS[:resource_reference].new(args)
  end

  def self.UpdateAltTextFilter(args = {})
    return FILTERS[:update_alt].new(args)
  end

  def self.UpdateHREFFilter(args = {})
    return FILTERS[:update_href].new(args)
  end
end
