module UMPTG::Fulcrum::Resources
  require_relative(File.join("filter", "embedlinkfilter"))
  require_relative(File.join("filter", "fulcrumcssfilter"))
  require_relative(File.join("filter", "resourcereferencefilter"))
  require_relative(File.join("filter", "updatealttextfilter"))

  FILTERS = {
      embed_link: Filter::EmbedLinkFilter,
      fulcrum_css: Filter::FulcrumCSSFilter,
      resource_reference: Filter::ResourceReferenceFilter,
      update_alt: Filter::UpdateAltTextFilter
    }

  def self.EmbedLinkFilter(args = {})
    return Filter::EmbedLinkFilter.new(args)
  end

  def self.ResourceReferenceFilter(args = {})
    return Filter::ResourceReferenceFilter.new(args)
  end

  def self.UpdateAltTextFilter(args = {})
    return Filter::UpdateAltTextFilter.new(args)
  end

  def self.FulcrumCSSFilter(args = {})
    return Filter::FulcrumCSSFilter.new(args)
  end
end
