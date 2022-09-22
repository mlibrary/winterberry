module UMPTG::Review

  #
  class Action < UMPTG::Action
    attr_reader :review_msg_list, :fragment
    attr_accessor :has_elements

    def initialize(args = {})
      super(args)

      @name = @properties[:name]
      @fragment = @properties[:fragment]

      @has_elements = {}
      @review_msg_list = []
    end

    def process(args = {})
      children = @properties[:children]
      classes = @properties[:classes]

      unless children.nil?
        children.each do |e|
          @has_elements[e] = false
        end
      end
      unless classes.nil?
        classes.each do |e|
          @has_elements["@#{e}"] = false
        end
      end

      x = ".//*[#{Action.element_xpath(children)} or #{Action.class_xpath(classes)}]" unless children.nil? or classes.nil?
      x = ".//*[#{Action.element_xpath(children)}]" if !children.nil? and classes.nil?
      x = ".//*[#{Action.class_xpath(classes)}]" if children.nil? and !classes.nil?
      nodes = @fragment.node.xpath(x)
      #puts "#{__method__},#{@name}:nodes=#{nodes.count},x=#{x}"
      nodes.each do |node|
        node_name = node.name
        if !node.namespace.nil? and !node.namespace.prefix.nil?
          node_name = node.namespace.prefix + ":" + node.name
        end
        @has_elements[node_name] = true if @has_elements.has_key?(node_name)
        @has_elements["@#{node['class']}"] = true if @has_elements.has_key?("@#{node['class']}")
      end

      # Attach the list XML fragment objects processed to this
      # Action and set it status COMPLETED.
      #@object_list = olist
      @status = Action.COMPLETED
    end

    def to_s
      return @review_msg_list.join("\n")
    end

    def add_msg(args = {})
      raise "Missing :level parameter" unless args.key?(:level)
      raise "Missing :text parameter" unless args.key?(:text)

      @review_msg_list << UMPTG::Message.new(
                level: args[:level],
                text: args[:text]
              )
    end

    def add_info_msg(txt = "")
      add_msg(
          level: UMPTG::Message.INFO,
          text: txt
      )
    end

    def add_warning_msg(txt = "")
      add_msg(
          level: UMPTG::Message.WARNING,
          text: txt
      )
    end

    def add_error_msg(txt = "")
      add_msg(
          level: UMPTG::Message.ERROR,
          text: txt
      )
    end

    def add_fatal_msg(txt = "")
      add_msg(
          level: UMPTG::Message.FATAL,
          text: txt
      )
    end

    def self.element_xpath(elements = [])
      xpath = elements.collect do |e|
        e.index(":").nil? ? "local-name()=\"#{e}\"" : "name()=\"#{e}\""
      end
      return "#{xpath.join(' or ')}"
    end

    def self.class_xpath(class_values = [])
      xpath = class_values.collect { |cl| "@class=\"#{cl}\"" }
      return "#{xpath.join(' or ')}"
    end
  end
end
