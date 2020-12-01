# Base class for fragment selectors. Empty for now.
module UMPTG::Fragment
  class Selector
    def select_element(name, attrs = [])
      raise "Error: this method must be implemented."
    end

    def select_comment(string)
      return false
    end
  end
end
