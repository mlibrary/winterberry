module UMPTG::Fulcrum::Resources
  require_relative(File.join("filter", "alttextfilter"))
  require_relative(File.join("filter", "embedlinkfilter"))
  require_relative(File.join("filter", "fulcrumcssfilter"))
  require_relative(File.join("filter", "opffilter"))
  require_relative(File.join("filter", "removefigcaptionfilter"))
  require_relative(File.join("filter", "resourcereferencefilter"))
  require_relative(File.join("filter", "updatealttextfilter"))
  require_relative(File.join("filter", "updatehreffilter"))

  FILTERS = {
      alt_text: Filter::AltTextFilter,
      embed_link: Filter::EmbedLinkFilter,
      fulcrum_css: Filter::FulcrumCSSFilter,
      opf: Filter::OPFFilter,
      remove_figcaption: Filter::RemoveFigcaptionFilter,
      resource_reference: Filter::ResourceReferenceFilter,
      update_alt: Filter::UpdateAltTextFilter,
      update_href: Filter::UpdateHREFFilter
    }

  def self.AltTextFilter(args = {})
    return FILTERS[:alt_text].new(args)
  end

  def self.EmbedLinkFilter(args = {})
    return FILTERS[:embed_link].new(args)
  end

  def self.FulcrumCSSFilter(args = {})
    return FILTERS[:fulcrum_css].new(args)
  end

  def self.OPFFilter(args = {})
    return FILTERS[:opf].new(args)
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
