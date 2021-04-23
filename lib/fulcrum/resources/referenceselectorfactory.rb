module UMPTG::Fulcrum::Resources

  # Class processes each resource reference found within XML content.
  class ReferenceSelectorFactory
    def self.select(args = {})
      vendor = args[:vendor]

      unless vendor.nil?
        case vendor
        when :apex
          return ApexReferenceSelector.new
        when :newgen
          return NewgenReferenceSelector.new
        when :default
          return SpecReferenceSelector.new
        end
      end
      
      # Default selector
      raise "Error: invalid vendor #{vendor}"
    end
  end
end
