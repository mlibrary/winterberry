module UMPTG::Fulcrum::Resources

  # Class processes each resource reference found within XML content.
  class ReferenceSelectorFactory
    def self.select(args = {})
      vendor = args[:vendor]

      unless vendor.nil?
        case vendor
        when 'apex'
          return ApexReferenceSelector.new
        when 'newgen'
          return NewgenReferenceSelector.new
        when 'rekihaku'
          return RekihakuReferenceSelector.new
        else
        end
      end
      
      # Default selector
      return SpecReferenceSelector.new
    end
  end
end
