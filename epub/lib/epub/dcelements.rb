module UMPTG::EPUB

  class DCElements < Node

    NAMESPACE_URI = "http://purl.org/dc/elements/1.1/"

    def initialize(args = {})
      a = args.clone
      a[:xpath_children] ="//*[local-name()='metadata']/*[namespace-uri()='#{NAMESPACE_URI}']"
      super(a)
    end

    def title(args = {})
      return find(element_name: "title")
    end

    def identifier(args = {})
      return find(element_name: "identifier")
    end

    def find(args = {})
      return children if args.empty?

      return children.select {|n| n.name == args[:element_name]} \
            unless args[:element_name].nil?
    end

    def add(args = {})
      raise "not implemented"
    end

    def self.NAMESPACE_URI
      return NAMESPACE_URI
    end
  end
end
