module UMPTG::Fulcrum::Resources::XHTML::Pipeline
  require_relative(File.join("filter", "embedlinkfilter"))
  require_relative(File.join("filter", "updatehreffilter"))

  FILTERS = {
      xhtml_embed_link: Filter::EmbedLinkFilter,
      xhtml_update_href: Filter::UpdateHREFFilter
    }

  def self.EmbedLinkFilter(args = {})
    return FILTERS[:xhtml_embed_link].new(args)
  end

  def self.UpdateHREFFilter(args = {})
    return FILTERS[:xhtml_update_href].new(args)
  end

  def self.FILTERS
    return FILTERS
  end
end
