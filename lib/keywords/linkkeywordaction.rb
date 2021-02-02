module UMPTG::Keywords
  require 'erb'

  class LinkKeywordAction < UMPTG::Action
    attr_accessor :name, :keyword_container

    def initialize(args = {})
      super(args)

      @noid = @properties[:noid]
      @keyword_container = @properties[:keyword_container]
    end

    def process()
      keyword = ERB::Util.url_encode(@keyword_container.text)
      href = "https://www.fulcrum.org/concern/monographs/#{@noid}?f%5Bkeywords_sim%5D%5B%5D=#{keyword}"
      link_markup = "<a href=\"#{href}\">#{@keyword_container.text}</span>"
      link_fragment = Nokogiri::XML.fragment(link_markup)
      @keyword_container.content = nil
      @keyword_container.add_child(link_fragment)

      @status = UMPTG::Action.COMPLETED
    end
  end
end