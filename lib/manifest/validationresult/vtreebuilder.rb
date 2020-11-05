module UMPTG::Manifest::ValidationResult
  class VTreeBuilder
    @@handler = nil
    @@parser = nil

    def self.build(markup)
      @@handler = VSaxDocument.new if @@handler.nil?
      @@handler.reset
      @@parser = Nokogiri::XML::SAX::PushParser.new(@@handler) if @@parser.nil?

      line_num = 0
      markup.each_line do |line|
        line_num += 1
        @@handler.line_num = line_num
        begin
          @@parser << line
        rescue Exception => e
          puts line
          puts "Line: #{line_num}"
          puts e.message
          return nil
        end
      end
      return VTree.new(:line_map => @@handler.line_map)
    end
  end
end
