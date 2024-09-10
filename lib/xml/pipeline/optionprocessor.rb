module UMPTG::XML::Pipeline

  class OptionProcessor < UMPTG::XML::Pipeline::Processor

    def initialize(args = {})
      a = args.clone
      options = args[:options]
      options = options.nil? ? {} : options

      filters = args[:filters]
      a[:filters] = {}
      options.each do |k,v|
        next unless v

        cl = filters[k]
        raise "undefined filter #{k}" if cl.nil?

        a[:filters][k] = cl.new(args)
      end
      raise "No filters defined" if a[:filters].empty?

      super(a)
    end
  end
end
