module UMPTG::Fulcrum::Metadata

  # Class represents resources references figures/images
  # found when processing an EPUB. The super contains
  # the figure/image fragment while this class extends
  # the base to include the figure caption and associated
  # resource name.
  class FigureObject < UMPTG::Object
    attr_accessor :caption, :name, :node

    # Arguments:
    #   :node         XML fragment node, @src contains resource name.
    #   :name         Fragment identifier, e.g. EPUB entry name.
    #   :caption      Resource caption
    def initialize(args = {})
      super(args)
      @node = @properties[:node]
      @resource_name = @node['src']
      @name = @properties[:name]
      @caption = @properties[:caption]
    end

    def map
      m = {}
      @node.each do |attr,value|
        m[attr] = value
      end
      m['resource_name'] = @resource_name
      m['caption'] = @caption
      return m
    end
  end
end
