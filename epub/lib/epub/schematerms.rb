module UMPTG::EPUB

  class SchemaTerms < Node

    def initialize(args = {})
      @ns_prefix = "schema"

      a = args.clone
      a[:xpath_children] ="//*[local-name()='metadata']/*[local-name()='meta' and starts-with(@property,concat('#{@ns_prefix}',':'))]"
      super(a)
    end

    def accessMode(args = {})
      return find(meta_property: "accessMode")
    end

    def find(args = {})
      return children if args.empty?

      return children.select {|n| n['property'] == "#{@ns_prefix}:#{args[:meta_property]}" } \
            unless args[:meta_property].nil?
    end

    def add(args = {})
      raise "not implemented"
    end
  end
end
