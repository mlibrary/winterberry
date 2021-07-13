module UMPTG::Remediation

  # Class processes each resource reference found within XML content.
  class DefaultProcessor < UMPTG::EPUB::EntryProcessor

    # Processing parameters:
    #   :logger                 Log messages
    def initialize(args = {})
      super(args)

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

      reference_action_list = []

      # Select the elements that have the invalid @margin-top.
      reference_container_list = xml_doc.xpath("//*[@margin-top!='']")
      reference_container_list.each do |refnode|
        reference_action_list << RemoveMarginTopAction.new(
                        name: name,
                        reference_node: refnode
                      )
      end

      # Select the elements that have the invalid @margin-bottom.
      reference_container_list = xml_doc.xpath("//*[@margin-bottom!='']")
      reference_container_list.each do |refnode|
        reference_action_list << RemoveMarginBottomAction.new(
                        name: name,
                        reference_node: refnode
                      )
      end

      # Select the elements that have the invalid @text-align.
      reference_container_list = xml_doc.xpath("//*[@text-align!='']")
      reference_container_list.each do |refnode|
        reference_action_list << RemoveTextAlignAction.new(
                        name: name,
                        reference_node: refnode
                      )
      end

      # Select the elements that have the invalid @id values.
      reference_container_list = xml_doc.xpath("//*[number(@id) >= 0]")
      reference_container_list.each do |refnode|
        reference_action_list << FixIdAction.new(
                        name: name,
                        reference_node: refnode
                      )
      end

      # Select the elements that have the invalid @href values.
      reference_container_list = xml_doc.xpath("//*[local-name()='a' and starts-with(@href,'http:')=false() and starts-with(@href,'#')=false()]")
      reference_container_list.each do |refnode|
        n_list = refnode.document.xpath("//*[@id='#{refnode['href']}']")
        if n_list.count > 0
          reference_action_list << FixHrefAction.new(
                        name: name,
                        reference_node: refnode
                      )
        end
      end

      # Select empty title elements.
      reference_container_list = xml_doc.xpath("//*[local-name()='title' and normalize-space(.)='']")
      reference_container_list.each do |refnode|
        reference_action_list << FixTitleAction.new(
                      name: name,
                      reference_node: refnode
                    )
      end

      # Select invalid image/@width values.
      reference_container_list = xml_doc.xpath("//*[local-name()='img']")
      reference_container_list.each do |refnode|
        if refnode.key?('width')
          width = refnode['width'].strip.downcase
          if width.match?(/^[0-9]?[a-z]?/)
            reference_action_list << FixImageWidthAction.new(
                          name: name,
                          reference_node: refnode
                        )
          end
        end
      end

      # Process all the Actions for this XML content.
      reference_action_list.each do |action|
        action.process()
      end

      # Return the list of Actions which contains the status
      # for each.
      return reference_action_list
    end

    private
  end
end
