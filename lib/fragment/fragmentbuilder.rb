class FragmentBuilder
  @@parser = nil
  @@processor = FragmentSaxDocument.new

  def self.parse(args = {})
    if args.has_key?(:file_name)
      file_name = args[:file_name]
      content = File.read(file_name)
    else
      content = args[:content]
    end
    raise "Error: no content specified." if content.nil? or content.empty?

    containers = args[:containers]
    raise "Error: no containers specified." if containers.nil? or containers.empty?

    info = args[:info]
    raise "Error: no info specified." if info.nil?

    @@processor.reset
    @@processor.containers = containers
    @@processor.info = info
    @@processor.name = args[:name]

    @@parser = Nokogiri::XML::SAX::Parser.new(@@processor) if @@parser.nil?
    @@parser.parse(content)
    return @@processor.fragments
  end
end
