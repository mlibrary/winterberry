module UMPTG::EPUB::DocumentProcessors
  class FnProcessor < Processor
    attr_reader :fnref_count, :section_fnref, :fn_list

    def initialize(args = {})
      super(args)
      reset()
    end

    def process(args = {})
      super(args)

      fnref_node_list = @document.xpath("/*[local-name()='html']/*[local-name()='body']//*[local-name()='a' and @role='doc-noteref']")
      unless fnref_node_list.empty?
        @fnref_count += fnref_node_list.count
        section_node_list = @document.xpath("/*[local-name()='html']/*[local-name()='body']//*[local-name()='section' and @epub:type!='']")
        unless section_node_list.empty?
          section_node = section_node_list.first
          @section_fnref[section_node] = fnref_node_list
        end
      end

      @fn_list += @document.xpath("/*[local-name()='html']/*[local-name()='body']//*[@epub:type = 'footnote']")

=begin
      fnref_node_list.each_with_index do |fnref_node,ndx|
        new_ndx = ndx + 1
        fnref_node.content = new_ndx
        href = fnref_node['href']
        id = href.split("#").last
        @fnref_num[id] = new_ndx
      end

      fn_node_list = @document.xpath("/*[local-name()='html']/*[local-name()='body']//*[@epub:type = 'footnote']")
      fn_node_list.each do |fn_node|
        backlink_list = fn_node.xpath(".//*[@role='doc-backlink']")
        unless backlink_list.empty?
          backlink = backlink_list.first
          id = backlink['id']
          new_num = @fnref_num[id]
          backlink.content = new_num
        end
      end
=end
    end

    def reset()
      super()
      @fnref_count = 0
      @section_fnref = {}
      @fn_list = []
    end
  end
end
