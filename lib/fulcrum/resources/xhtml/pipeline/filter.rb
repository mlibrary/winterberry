module UMPTG::Fulcrum::Resources::XHTML::Pipeline
  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }

  FILTERS = {
      xhtml_embed_link: Filter::EmbedLinkFilter,
      xhtml_set_embed: Filter::SetEmbedFilter,
      xhtml_update_alt: Filter::UpdateAltFilter,
      xhtml_update_href: Filter::UpdateHREFFilter
    }

  def self.FILTERS
    return FILTERS
  end
end
