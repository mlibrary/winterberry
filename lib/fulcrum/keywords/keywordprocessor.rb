module UMPTG::Fulcrum::Keywords

  require 'nokogiri'

  class KeywordProcessor < UMPTG::EPUB::EntryProcessor

    # Parameters:
    #     :monograph_noid         Monograph NOID used for formatting URLs
    #     :logger                 Log messages
    def initialize(args = {})
      super(args)

      @monograph_noid = @properties[:monograph_noid]
      @selector = SpecKeywordSelector.new
      @logger = @properties[:logger]
    end

    # Method generates and processes a list of actions
    # for the specified XML content.
    #
    # Parameters:
    #   :name         Identifier associated with XML content
    #   :xml_doc      XML content document.
    def action_list(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      # Select the elements that contain resource references.
      keyword_list = @selector.references(xml_doc)

      # For each container element, determine the necessary actions.
      # A container may reference one or more resources. A reference
      # may be a resource that should be replaced with embed|link
      # markup or an additional resource that should be inserted.
      alist = []
      keyword_list.each do |keyword|
        next unless keyword['data-fulcrum-keyword-skip'].nil? or keyword['data-fulcrum-keyword-skip'].downcase != 'true'

        action = LinkKeywordAction.new(
                  keyword_container: keyword,
                  monograph_noid: @monograph_noid
                  )

        # Add the list of Actions for this container to
        # the list for the entire XML content.
        alist << action
      end

      # Process all the Actions for this XML content.
      alist.each do |action|
        action.process()
      end

      # Return the list of Actions which contains the status
      # for each.
      return alist
    end
  end
end
