module UMPTG::Review

  class LinkKeywordAction < NormalizeAction
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]

      keyword_skip = reference_node['data-fulcrum-keyword-skip'].nil? ? false : \
                reference_node['data-fulcrum-keyword-skip'].strip.downcase == 'true'
      keyword_query = reference_node['data-fulcrum-keyword']

      case
      when keyword_skip
        reference_node.remove_attribute('data-fulcrum-keyword')
      when keyword_query.nil?
        #reference_node['data-fulcrum-keyword'] = ""
        reference_node['data-fulcrum-keyword'] = nil
      end

      anchor_list = reference_node.xpath(".//*[local-name()='a' and starts-with(@href,'https://www.fulcrum.org/')]")
      anchor_list.each do |anchor|
        content = anchor.text
        anchor.replace(content)
      end
      reference_node.remove_attribute('data-fulcrum-keyword-skip')

      @status = NormalizeAction.NORMALIZED
    end
  end
end