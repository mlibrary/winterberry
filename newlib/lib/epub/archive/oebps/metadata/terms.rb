module UMPTG::EPUB::Archive::OEBPS::Metadata

  class Terms < Node

    def initialize(args = {})
      a = args.clone
      a[:xpath_node] = "//*[local-name()='metadata']"
      super(a)

      @ns_prefix = nil
      @xpath_children = "./*[local-name()='meta' and not(contains(@property,':'))]"
    end

    def add(args = {})
      meta_property = args[:meta_property] || ""
      meta_name = args[:meta_name] || ""
      meta_property_value = args[:meta_property_value] || ""
      meta_property_content = args[:meta_property_content] || ""
      append = args[:meta_property_append] || false

      mnode_list = find(args)
      m_list = mnode_list.select do |n|
        (!args[:meta_property_value].nil? and n.content == meta_property_value \
            or (!args[:meta_property_content].nil? and n['content'] == meta_property_content))
      end
      #puts "#{meta_property},#{meta_name}:#{meta_property_value},#{meta_property_content}"
      #puts "mnode_list:#{mnode_list.count},m_list:#{m_list.count}"
      if m_list.empty?
        if meta_property.empty?
          prop = @ns_prefix.nil? ? meta_name : @ns_prefix + ":" + meta_name
          markup = "<meta name=\"#{prop}\"/>"
        else
          prop = @ns_prefix.nil? ? meta_property : @ns_prefix + ":" + meta_property
          markup = "<meta property=\"#{prop}\"/>"
        end
        n = obj_node.add_child(markup)
        m_list << n.first unless n.first.nil?

        m_list.each do |n|
          n.content = meta_property_value unless args[:meta_property_value].nil?
          n['content'] = meta_property_content unless meta_property_content.empty?
        end
      end
      return m_list
    end

    def self.NAMESPACE_URI
      return NAMESPACE_URI
    end
  end
end
