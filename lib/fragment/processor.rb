 module UMPTG::Fragment

  require 'nokogiri'

  class Processor

    @@processor = nil

    def process(args = {})
      selector = args[:selector]
      #raise "Error: no selection processor specified." if selector.nil?
      selector = Selector.new if selector.nil?

      # Content may be provided via a name to a file
      # or text.
      if args.has_key?(:file_name)
        file_name = args[:file_name]
        content = File.read(file_name)
      else
        content = args[:content]
      end
      raise "Error: no content specified." if content.nil? or content.empty?

      # Parse the content, creating a list of fragments to be returned.
      @@processor = UMPTG::Fragment::XMLSaxDocument.new if @@processor.nil?
      @@processor.reset
      @@processor.name = args[:name]
      @@processor.selector = selector

      parser = Nokogiri::XML::SAX::Parser.new(@@processor)
      parser.parse(content)
      return @@processor.fragments
    end
  end
end
