module UMPTG::Keywords

  require 'nokogiri'

  class KeywordProcessor < UMPTG::EPUB::EntryProcessor
    def initialize(args = {})
      super(args)

      @monograph_noid = @properties[:noid]
      @selector = SpecKeywordSelector.new
    end

    # Method generates and processes a list of actions
    # for the specified XML content.
    #
    # Parameters:
    #   :name         Identifier associated with XML content
    #   :content      XML content.
    def action_list(args = {})
      name = args[:name]
      content = args[:content]

      # Create XML document tree from content.
      alist = []
      begin
        doc = Nokogiri::XML(content, nil, 'UTF-8')
      rescue Exception => e
        raise e.message
      end

      # Select the elements that contain resource references.
      keyword_list = @selector.references(doc)

      # For each container element, determine the necessary actions.
      # A container may reference one or more resources. A reference
      # may be a resource that should be replaced with embed|link
      # markup or an additional resource that should be inserted.
      alist = []
      keyword_list.each do |keyword|
        action = LinkKeywordAction.new(
                  keyword_container: keyword,
                  noid: @monograph_noid
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
