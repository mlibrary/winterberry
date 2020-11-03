module UMPTG::Fragment
  class ContainerSelector

    attr_accessor :containers

    def select_fragment(name, attrs = [])
      return @containers.include?(name)
    end
  end
end
