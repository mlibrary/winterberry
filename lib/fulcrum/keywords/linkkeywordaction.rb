module UMPTG::Fulcrum::Keywords
  require 'erb'

  class LinkKeywordAction < UMPTG::Action
    attr_accessor :name, :keyword_container

    def initialize(args = {})
      super(args)

      @monograph_noid = @properties[:monograph_noid]
      @keyword_container = @properties[:keyword_container]
    end

    def process()
      link_markup = "<a href=\"#{href}\">#{@keyword_container.text}</span>"
      link_fragment = Nokogiri::XML.fragment(link_markup)
      @keyword_container.content = nil
      @keyword_container.add_child(link_fragment)

      @status = UMPTG::Action.COMPLETED
    end

    def keyword
      return ERB::Util.url_encode(@keyword_container.text)
    end

    def href
      return "https://www.fulcrum.org/concern/monographs/#{@monograph_noid}?f%5Bkeywords_sim%5D%5B%5D=#{keyword}"
    end

    def to_s
      return super() + ", \"#{@keyword_container.text}\": #{href}"
    end
  end
end