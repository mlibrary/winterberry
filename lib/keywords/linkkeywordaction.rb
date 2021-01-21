module UMPTG::Keywords

  class LinkKeywordAction < Action
    def initialize(args = {})
      super(args)
      @noid = args[:noid]
    end

    def process()
      keyword = ERB::Util.url_encode(@reference_container.text)
      href = "https://www.fulcrum.org/concern/monographs/#{@noid}?f%5Bkeywords_sim%5D%5B%5D=#{keyword}"
      link_markup = "<a href=\"#{href}\">#{@reference_container.text}</span>"
      link_fragment = Nokogiri::XML.fragment(link_markup)
      @reference_container.content = nil
      @reference_container.add_child(link_fragment)

      @status = Action.COMPLETED
    end
  end
end