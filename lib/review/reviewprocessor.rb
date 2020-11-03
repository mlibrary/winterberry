module UMPTG::Review
  class ReviewProcessor < UMPTG::Fragment::Processor
    def process(args = {})
      fragments = super(args)

      review_fragments = []
      fragments.each do |frag|
        review_fragments << ReviewObject.new(
                              :node => frag.node,
                              :name => frag.name
                            )
      end

      children = args[:children]
      classes = args[:classes]

      unless children.nil? and classes.nil?
        review_fragments.each do |fragment|
          fragment.has_elements = {}

          unless children.nil?
            children.each do |e|
              fragment.has_elements[e] = false
            end
          end
          unless classes.nil?
            classes.each do |e|
              fragment.has_elements["@#{e}"] = false
            end
          end

          x = ".//*[#{element_xpath(children)} or #{class_xpath(classes)}]" unless children.nil? or classes.nil?
          x = ".//*[#{element_xpath(children)}]" if !children.nil? and classes.nil?
          x = ".//*[#{class_xpath(classes)}]" if children.nil? and !classes.nil?
          nodes = fragment.node.xpath(x)
          #puts "#{__method__}:nodes=#{nodes.count},x=#{x}"
          nodes.each do |node|
            node_name = node.name
            if !node.namespace.nil? and !node.namespace.prefix.nil?
              node_name = node.namespace.prefix + ":" + node.name
            end
            fragment.has_elements[node_name] = true if fragment.has_elements.has_key?(node_name)
            fragment.has_elements["@#{node['class']}"] = true if fragment.has_elements.has_key?("@#{node['class']}")
          end
        end
      end
      return review_fragments
    end

    def new_info(node)
      return ReviewObject.new(node)
    end

    def element_xpath(elements = [])
      xpath = elements.collect do |e|
        e.index(":").nil? ? "local-name()=\"#{e}\"" : "name()=\"#{e}\""
      end
      return "#{xpath.join(' or ')}"
    end

    def class_xpath(class_values = [])
      xpath = class_values.collect { |cl| "@class=\"#{cl}\"" }
      return "#{xpath.join(' or ')}"
    end
  end
end
