module UMPTG::EPUB::DocumentProcessors
  class Processor
    def initialize(args = {})
      reset()
    end

    def process(args = {})
      @name = args[:name]
      raise "Error: item name not specified" if @name.nil? or @name.empty?

      @document = args[:document]
      raise "Error: document not specified" if @document.nil?
    end

    def reset()
      @name = nil
      @document = nil
    end
  end
end
