module ExportModule
  require 'nokogiri'

  require_relative 'export/exportsaxdocument.rb'

  @@parser = nil

  # Load an XML resource map file.
  def self.parse(args = {})
    processor = ExportSaxDocument.new

    markup = args[:markup] if args.has_key?(:markup)
    markup = File.read(args[:xml_path]) if args.has_key?(:xml_path)
    #raise "#{__method__}: error, no markup specified" if markup.nil? or markup.empty?

    @@parser = Nokogiri::XML::SAX::Parser.new(processor) if @@parser.nil?
    @@parser.parse(markup)

    return processor
  end
end
