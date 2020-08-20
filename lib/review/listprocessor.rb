class ListProcessor < ReviewProcessor
  @@children = [ 'p' ]

  def process(args = {})
    args[:children] = @@children

    selector = ContainerSelector.new
    selector.containers = [ 'li' , 'dt', 'dd' ]
    args[:selector] = selector

    fragments = super(args)

    fragments.each do |fragment|
      fragment.has_elements.each do |elem_name, exists|
          fragment.review_msg_list << "Lists Warning:  list item containing a <#{elem_name}>." \
                if exists and fragment.node.name == 'li'
          fragment.review_msg_list << "Lists Warning:  definition term containing a <#{elem_name}>." \
                if exists and fragment.node.name == 'dt'
          fragment.review_msg_list << "Lists Warning:  definition list item containing a <#{elem_name}>." \
                if exists and fragment.node.name == 'dd'
      end
    end
    return fragments
  end
end
