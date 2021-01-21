module UMPTG::Keywords

  require 'nokogiri'

  class ReferenceProcessor

    def initialize(args = {})
      @selector = args[:selector]
      raise "Error: reference selector must be specified." if @selector.nil?

      @noid = args[:noid]
      raise "Error: noid must be specified." if @noid.nil?
    end

    def keyword_actions(args = {})
      xml_doc = args[:xml_doc]
      raise "Error: XML document must be specified." if xml_doc.nil?

      keyword_container_list = @selector.references(xml_doc)

      # For each reference found, create the appropriate action
      # to process the reference. A reference may be type
      # :element or :marker
      keyword_action_list = []
      keyword_container_list.each do |refnode|
        action = LinkKeywordAction.new(
                  reference_container: refnode,
                  noid: @noid
                  )
        keyword_action_list << action
      end
      return keyword_action_list
    end
  end
end
