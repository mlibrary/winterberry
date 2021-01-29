module UMPTG::FMetadata
  class MarkerAction < Action
    def process(args = {})
      # Marker fragment. If there is a comment,
      # then use it value. Otherwise use the
      # element content.
      rnames = []
      comment = @fragment.node.xpath(".//comment()")
      if comment.empty?
        rnames << fragment.node.text
      else
        comment.each do |c|
          r = c.text.match(/\<insert[ ]+([^\>]+)\>/)
          if r.nil? or r.empty?
            rn = c.text
          else
            rn = r[1]
          end
          rnames << rn
        end
      end

      olist = []
      rnames.each do |r|
        next if r.nil? or r.strip.empty?
        marker = UMPTG::FMetadata::MarkerObject.new(
                node: fragment.node,
                name: @properties[:name],
                resource_name: r
              )
        olist << marker
      end
      @object_list = olist
      @status = Action.COMPLETED
    end
  end
end
