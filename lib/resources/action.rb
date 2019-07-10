require 'nokogiri'

class Action
  def initialize(args)
    @action_args = args
  end

  def link_markup(metadata, descr = nil)
    descr = "View resource." if descr == nil

    link = metadata['link']
    link = link.match('^[^\(]+\(\"([^\"]+)\".*') {|m| m[1] }
    embed_markup = "<a href=\"#{link}\" target=\"_blank\">#{descr}</a>"
    embed_markup
  end
end