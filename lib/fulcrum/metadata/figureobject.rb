module UMPTG::Fulcrum::Metadata

  # Class represents resources references figures/images
  # found when processing an EPUB. The super contains
  # the figure/image fragment while this class extends
  # the base to include the figure caption and associated
  # resource name.
  class FigureObject < UMPTG::Fragment::Object
    attr_accessor :caption

    # Arguments:
    #   :node         XML fragment node, @src contains resource name.
    #   :name         Fragment identifier, e.g. EPUB entry name.
    #   :caption      Resource caption
    def initialize(args = {})
      super(args)

      @resource_name = nil
      case @node.name
      when 'img'
        @resource_name = @node['src']
      when 'video'
        nl = @node.xpath(".//*[local-name()='source' and @src]")
        @resource_name = nl.first['src'] unless nl.empty?
      end
      raise "#{@node.name} unsupported figure object." if @resource_name.nil?

      @caption = @properties[:caption]
    end

    def map
      row = super()
      row['resource_name'] = @resource_name
      row['caption'] = @caption
      return row
    end
  end
end
