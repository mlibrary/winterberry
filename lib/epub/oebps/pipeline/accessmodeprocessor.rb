module UMPTG::EPUB::OEBPS::Pipeline
  class AccessModeProcessor < UMPTG::XML::Pipeline::Processor
    def run(xml_doc, args = {})
      actions = []

      unless @xpath.empty?
        a = args.clone()
        a[:name] = @name

        attribute_value = "textual"
        markup = "<meta property=\"schema:accessModeSufficient\">#{attribute_value}</meta>"

        node_list = xml_doc.xpath(@xpath)
        ams_list = node_list.select {|n| n["property"] == "schema:accessModeSufficient"}

        node_list.each do |n|
          next if ams_list.include?(n)
          actions << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: n,
                 info_message: "#{name}, found #{n}"
             )

        end

        case ams_list.count
        when 1
          actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    name: name,
                    reference_node: ams_list.first,
                    action: :add_next,
                    markup: markup,
                    warning_message: "#{name}, missing markup #{ams_list.first}"
                  )
        else
          actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    name: name,
                    reference_node: ams_list[1],
                    action: :replace_content,
                    markup: attribute_value,
                    warning_message: "#{name}, duplicate markup #{ams_list[1]}"
                  )
          ams_list[2..-1].each do |n|
            actions << UMPTG::XML::Pipeline::Actions::RemoveElementAction.new(
                      name: name,
                      reference_node: n,
                      action_node: n,
                      warning_message: "#{name}, duplicate markup #{n}"
                    )
          end
        end
=begin
        xml_doc.xpath(@xpath).each do |n|
          a[:reference_node] = n
          @filters.each do |f|
            a[:name] = f.name
            actions += f.create_actions(a)
          end
        end
=end
      end

      # Return XML::ActionResult
      args[:actions] = actions
      args[:logger] = @logger
      return UMPTG::XML::Pipeline::Action.process_actions(args)
    end
  end
end
