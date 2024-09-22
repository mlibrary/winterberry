module UMPTG::EPUB

  class Metadata < Node
    attr_reader :dc, :schema, :terms

    CHILDREN_XPATH = <<-NTEMP
    //*[
    local-name()='metadata'
    ]/*[
    namespace-uri()='%s'
    or @*[
    namespace-uri()='%s'
    ]
    ]|//*[
    local-name()='metadata'
    ]/*[
    local-name()='meta' and starts-with(@property,concat('%s',':'))
    ]
    NTEMP

    def initialize(args = {})
      a = args.clone
      a[:xpath_node] = "//*[local-name()='metadata']"
      a[:xpath_children] = "//*[local-name()='metadata']/*"
      super(a)

      @dc = DC.new(a)
      @schema = Schema.new(a)
      @terms = Terms.new(a)

      @xpath_children = @terms.xpath_children + '|' + @dc.xpath_children \
              + '|' + @schema.xpath_children
    end

    def add(args = {})
      raise "not implemented"
    end

    def select(node, args)
      return (@terms.select(node, args) or @dc.select(node, args) or @schema.select(node, args))
    end

    def self.namespace_prefix(onode, ns_attr_uri)
      ns_list = onode.namespace_definitions()
      ns_attr = ns_list.find {|ns| ns.href == ns_attr_uri }
      return ns_attr.nil? ? "zzzz" : ns_attr.prefix
    end

    def self.find_children(onode, args = {})
      xpath_args = []

      nme_args = []
      nme_args << "local-name()='#{args[:element_name]}'" \
            unless args[:element_name].nil?
      nme_args << "namespace-uri()='#{args[:namespace_element_uri]}'" \
            unless args[:namespace_element_uri].nil?
      xpath_args << "./*[" + nme_args.join(" and ") + "]" unless nme_args.empty?


      xpath_args << "./*[local-name()='meta' and @property='#{args[:meta_property]}']" \
            unless args[:meta_property].nil?
      xpath_args << "./*[local-name()='meta' and @name='#{args[:meta_name]}']" \
            unless args[:meta_name].nil?

      if nme_args.empty?
        ns_args = []
        ns_args << "namespace-uri()='#{args[:namespace_element_uri]}'" \
              unless args[:namespace_element_uri].nil?
        ns_args << "@*[namespace-uri()='#{args[:namespace_attribute_uri]}']" \
              unless args[:namespace_attribute_uri].nil?
        xpath_args << "./*[" + ns_args.join(" or ") + "]" unless ns_args.empty?

        xpath_args << "./*[local-name()='meta' and starts-with(@property,concat('#{args[:namespace_attribute_prefix]}',':'))]" \
              unless args[:namespace_attribute_prefix].nil?
      end

      xpath = xpath_args.join('|')
      return onode.xpath(xpath)
    end
  end
end
