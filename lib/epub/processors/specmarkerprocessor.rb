module UMPTG::EPUB::Processors
  class SpecMarkerProcessor < UMPTG::Fragment::Processor
    @@markerselector = nil

    attr_reader :img_list

    def initialize
      super()
      reset
    end

    def process(args = {})
      @@markerselector = SpecMarkerSelector.new if @@markerselector.nil?
      args[:selector] = @@markerselector

      fragments = super(args)

      fragments.each do |fragment|
        # Marker fragment. If there is a comment,
        # then use it value. Otherwise use the
        # element content.

        comment = fragment.node.xpath(".//comment()")
        resource_name = comment.empty? ? fragment.node.text : comment.first.text

        unless resource_name.nil? or resource_name.strip.empty?
          marker = Marker.new(
                  :node => fragment.node,
                  :name => args[:name],
                  :resource_name => resource_name
                )
          @img_list << marker
        end
      end
      return fragments
    end

    def reset
      @img_list = []
    end
  end
end
