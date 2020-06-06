class FragmentBuilder

  def self.parse(args = {})
    if args.has_key?(:file_name)
      file_name = args[:file_name]
      content = File.read(file_name)
    else
      content = args[:content]
    end
    raise "Error: no content specified." if content.nil? or content.empty?

    info = args[:info]
    raise "Error: no info specified." if info.nil?

    selectproc = args[:selectproc]
    raise "Error: no selection processor specified." if selectproc.nil?

    #selectproc = @@processor if selectproc.nil?
    selectproc.reset
    selectproc.info = info
    selectproc.name = args[:name]

    parser = Nokogiri::XML::SAX::Parser.new(selectproc)
    parser.parse(content)
    return selectproc.fragments
  end
end
