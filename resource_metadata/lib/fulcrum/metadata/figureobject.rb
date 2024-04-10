module UMPTG::Fulcrum::Metadata

  # Class represents resources references figures/images
  # found when processing an EPUB. The super contains
  # the figure/image fragment while this class extends
  # the base to include the figure caption and associated
  # resource name.
  class FigureObject < MarkerObject
    attr_accessor :alt_text, :caption_text

    # Arguments:
    #   :node         XML fragment node, @src contains resource name.
    #   :name         Fragment identifier, e.g. EPUB entry name.
    #   :caption      Resource caption
    def initialize(args = {})
      super(args)

      @node = @properties[:node]
      case @node.name
      when 'img'
        rname = @node['src']
      when 'audio', 'video'
        nl = @node.xpath(".//*[local-name()='source' and @src]")
        rname = nl.first['src'] unless nl.empty?
      end
      @resource_name = (rname.nil? or rname.strip.empty?) ? "" : File.basename(rname.strip)

      raise "#{@node.name} unsupported figure object." if @resource_name.empty?

      @caption = @properties[:caption]
      @caption_text = @caption.nil? ? "" : \
            @caption.text.strip.gsub(/[\n]+/, ' ')

      @alt_text = @node.has_attribute?("alt") ? @node["alt"] : ""
    end
  end
end
