module UMPTG::EPUB

  class Terms < Node

    def initialize(args = {})
      a = args.clone
      a[:xpath_children] ="//*[local-name()='metadata']/*[local-name()='meta' and not(contains(@property,':'))]"
      super(a)
    end

    def find(args = {})
      return children if args.empty?

      return children.select {|n| n['property'] == "#{args[:meta_property]}" } \
            unless args[:meta_property].nil?
    end

    def add(args = {})
      raise "not implemented"
    end
  end
end
