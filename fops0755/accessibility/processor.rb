module UMPTG::Accessibility

  class << self
    def OPFFilter(args = {})
      return Filter::OPFFilter.new(args)
    end

=begin
    def NCXFilter(args = {})
      return Filter::NCXFilter.new(args)
    end

    def XHTMLFilter(args = {})
      return Filter::XHTMLFilter.new(args)
    end
=end
  end

  class Processor < UMPTG::XML::Pipeline::Processor
    def initialize(args = {})
      args[:filters] = FILTERS
      super(args)
    end
  end
end
