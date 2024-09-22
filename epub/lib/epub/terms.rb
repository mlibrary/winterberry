module UMPTG::EPUB

  class Terms < Node

    def initialize(args = {})
      a = args.clone
      a[:xpath_children] ="./*[local-name()='meta' and not(contains(@property,':'))]"
      super(a)

      @ns_prefix = nil
    end

    def add(args = {})
      raise "not implemented"
    end
  end
end
