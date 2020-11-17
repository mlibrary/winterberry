# Base class for fragment selectors. Empty for now.
module UMPTG::Fragment
  class Selector
    def select_fragment(name, attrs = [])
      raise "Error: this method must be implemented."
    end
  end
end
