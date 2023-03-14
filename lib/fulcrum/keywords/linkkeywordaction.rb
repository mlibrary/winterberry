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

      k = @keyword_container['data-fulcrum-keyword']
      @keyword_container.remove_attribute('data-fulcrum-keyword') if k.nil? or k.empty?

      @status = UMPTG::Action.COMPLETED
    end

    def keyword
      k = @keyword_container['data-fulcrum-keyword']
      k = @keyword_container.text if k.nil? or k.empty?
      return ERB::Util.url_encode(k)
    end

    def href
      return "https://www.fulcrum.org/concern/monographs/#{@monograph_noid}?f%5Bkeyword_sim%5D%5B%5D=#{keyword}"
    end

    def to_s
      return super() + ", \"#{@keyword_container.text}\": #{href}"
    end
  end
end