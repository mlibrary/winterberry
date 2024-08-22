module UMPTG::Fulcrum::Resources
  require_relative(File.join("filter", "embedlinkfilter"))
  require_relative(File.join("filter", "fulcrumcssfilter"))
  require_relative(File.join("filter", "updatealttextfilter"))

  def self.EmbedLinkFilter(args = {})
    return Filter::EmbedLinkFilter.new(args)
  end

  def self.FulcrumCSSFilter(args = {})
    return Filter::FulcrumCSSFilter.new(args)
  end
end
