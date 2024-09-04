module UMPTG::Fulcrum::Resources

  class Processor < UMPTG::XML::Pipeline::Processor

    def initialize(args = {})
      a = args.clone

      options = a[:options]
      options = options.nil? ? {} : options

      a[:filters] = {}
      options.each do |k,v|
        next unless v

        cl = FILTERS[k]
        raise "undefined filter #{k}" if cl.nil?

        a[:filters][k] = cl.new(args)
      end
      raise "No filters defined" if a[:filters].empty?

      super(a)
    end
  end
end
