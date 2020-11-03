module UMPTG::Review
  class TableProcessor < ReviewProcessor
    @@children = [ 'caption', 'colgroup', 'thead', 'tbody', 'tfoot' ]

    def process(args = {})
      args[:children] = @@children

      selector = UMPTG::Fragment::ContainerSelector.new
      selector.containers = [ 'table' ]
      args[:selector] = selector

      fragments = super(args)

      fragments.each do |fragment|
        fragment.has_elements.each do |key, exists|
          fragment.review_msg_list << "Table INFO:     has <#{key}>" if exists
          fragment.review_msg_list << "Table Warning:  has no <#{key}>" unless exists
        end
      end
      return fragments
    end
  end
end
