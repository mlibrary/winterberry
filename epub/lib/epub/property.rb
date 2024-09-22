module UMPTG::EPUB

  class Property < Node
    attr_reader :dcterms_modified

    def initialize(args = {})
      a = args.clone
      a[:xpath_children] = "//*[local-name()='metadata']/*[local-name()='meta']"
      super(a)
    end

    def find(args = {})
      entry_properties = args[:meta_properties]
      return children if entry_properties.nil? or entry_properties.strip.empty?

      props = entry_properties.split(' ')
      return children.select {|c| props.include?(c['property'])}
    end

    def add(args = {})
      property = args[:property]
      raise "missing meta property" if property.nil? or property.strip.empty?

      property_value = args[:value]

      metadata_node_list = find(meta_properties: property)
      if metadata_node_list.empty?
        metadata_node = obj_node.add_child("<meta/>").first
        metadata_node['property'] = property
        metadata_node_list << metadata_node
      end
      metadata_node_list.each {|n| n.content = property_value }

      return metadata_node_list.first.content
    end
  end
end
