class ReviewProcessor < FragmentProcessor
  def process(args = {})
    fragments = super(args)

    children = args[:children]
    classes = args[:classes]

    if !children.nil? or !classes.nil?
      fragments.each do |fragment|
        fragment.has_elements = {}
        if !children.nil?
          children.each do |e|
            fragment.has_elements[e] = false
          end
        end
        if !classes.nil?
          classes.each do |e|
            fragment.has_elements["@#{e}"] = false
          end
        end

        x = ".//*[#{element_xpath(children)} or #{class_xpath(classes)}]" unless children.nil? or classes.nil?
        x = ".//*[#{element_xpath(children)}]" if !children.nil? and classes.nil?
        x = ".//*[#{class_xpath(classes)}]" if children.nil? and !classes.nil?
        nodes = fragment.node.xpath(x)
        nodes.each do |node|
          fragment.has_elements[node.name] = true if fragment.has_elements.has_key?(node.name)
          fragment.has_elements["@#{node['class']}"] = true if fragment.has_elements.has_key?("@#{node['class']}")
        end
      end
    end
    return fragments
  end

  def new_info(node)
    return ReviewInfo.new(node)
  end

  def element_xpath(elements = [])
    xpath = elements.collect do |e|
      "local-name()=\"#{e}\""
    end
    return "#{xpath.join(' or ')}"
  end

  def class_xpath(class_values = [])
    xpath = class_values.collect { |cl| "@class=\"#{cl}\"" }
    return "#{xpath.join(' or ')}"
  end
end
