class FragmentProcessor

  @@processor = nil

  def process(args = {})
    selector = args[:selector]
    raise "Error: no selection processor specified." if selector.nil?

    if args.has_key?(:file_name)
      file_name = args[:file_name]
      content = File.read(file_name)
    else
      content = args[:content]
    end
    raise "Error: no content specified." if content.nil? or content.empty?

    @@processor = FragmentSaxDocument.new if @@processor.nil?
    @@processor.reset
    @@processor.name = args[:name]
    @@processor.selector = selector

    parser = Nokogiri::XML::SAX::Parser.new(@@processor)
    parser.parse(content)
    return @@processor.fragments
  end
end
