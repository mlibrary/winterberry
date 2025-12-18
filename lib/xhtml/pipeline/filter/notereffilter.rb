module UMPTG::XHTML::Pipeline::Filter

  class NoterefFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='a' and @epub:type='noteref'
    ]
    SXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :xhtml_noteref
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <a> element
      entry = args[:entry]

      action_list = []

      if reference_node.name == 'a'
        href = (reference_node["href"] || "").strip
        if href.empty?
          action_list << UMPTG::XML::Pipeline::Action.new(
                   name: name,
                   reference_node: reference_node,
                   warning_message: "#{name}, no href #{reference_node}"
                )
        else
          # reference_node is the note reference.
          # Below is an example of a note reference:
          #   <a id="pref_1"></a><span class="t16"><a href="#pref1_1" epub:type="noteref">1</a></span>
          # The node previous to the parent is the backlink
          # target (@id='pref_1').
          #
          # Below is an example of a note.
          #   <p class="p11">
          #   <a id="pref_1r"></a>
          #   <a href="008.html#pref_1"><span class="t13">1</span></a>
          #   <span class="t13">...</span>
          #   </p>
          # The node @id='pref_1r' is the note target. The node
          # @href='008.html#pref_1' is the backlink.
          #
          # Below are the steps:
          #   1. The note reference @id is set to the value of the backlink
          #      target @id='pref_1'.
          #   2. The backlink target node is removed.
          #   3. Using the backlink target @id (pref_1), the document is searched
          #      for the backlink which is located within the note (@href='008.html#pref_1').
          #   4. The back link @id is set to the value of the note target @id='pref_1r'.
          #   5. The note target node is removed.
          #   6. The note reference @href is set the note target @href='#pref_1r'.
          #
          ref_node = reference_node.parent.previous
          ref_id = ref_node["id"]

          hr = File.basename(entry.name) + "#" + ref_id
          rdoc = reference_node.document
          #rdoc = entry.files.find(entry_name: "Ops/017.xhtml").first.document
          tnode = rdoc.xpath("//*[@href='#{hr}']").first
          target_node = tnode.nil? ? nil : tnode.previous
          target_id = target_node.nil? ? "" : target_node["id"]

          if ref_node.nil? or target_node.nil?
            action_list << UMPTG::XML::Pipeline::Action.new(
                     name: name,
                     reference_node: reference_node,
                     warning_message: "#{name}, #{href} no ids found #{ref_id},#{target_id}"
                  )
          else
            action_list << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                     name: name,
                     reference_node: reference_node,
                     attribute_name: "id",
                     attribute_value: ref_id,
                     info_message: "#{name}, #{reference_node}"
                  )
            action_list << UMPTG::XML::Pipeline::Actions::RemoveElementAction.new(
                     name: name,
                     reference_node: reference_node,
                     action_node: ref_node,
                     info_message: "#{name}, #{ref_node}"
                  )
            action_list << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                     name: name,
                     reference_node: reference_node,
                     attribute_name: "href",
                     attribute_value: File.basename(e.name) + "#" + target_id,
                     info_message: "#{name}, #{reference_node}"
                  )
            new_target_node = target_node.xpath("./ancestor::*[local-name()='p'][1]").first
            action_list << UMPTG::XML::Pipeline::Actions::RemoveElementAction.new(
                     name: name,
                     reference_node: new_target_node,
                     action_node: target_node,
                     info_message: "#{name}, #{target_node}"
                  )
            action_list << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                     name: name,
                     reference_node: new_target_node,
                     attribute_name: "id",
                     attribute_value: target_id,
                     info_message: "#{name}, #{reference_node}"
                  )
          end
        end
      end
      return action_list
    end
  end
end
