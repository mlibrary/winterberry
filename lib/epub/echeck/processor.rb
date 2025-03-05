module UMPTG::EPUB::ECheck

  class << self
    def NCXFilter(args = {})
      return Filter::NCXFilter.new(args)
    end

=begin
    def OPFFilter(args = {})
      return Filter::OPFFilter.new(args)
    end
=end
    def XHTMLFilter(args = {})
      return Filter::XHTMLFilter.new(args)
    end
  end

  class Processor < UMPTG::XML::Pipeline::Processor
    def initialize(args = {})
      args[:filters] = FILTERS
      super(args)
    end
  end
end
