module UMPTG::EPUB

  require 'zip'

  class Entry < UMPTG::Object
    attr_accessor :content
    
    def initialize(args = {})
      super(args)

      # Process the entry content
      case
      when @properties.key?(:content)
        @content = @properties[:content]
      when @properties.key?(:zip_entry)
        @content = @properties[:zip_entry].get_input_stream.read
      else
        raise "Error: missing entry content" if @properties[:content].nil? and @properties[:zip_entry].nil?
      end

      @xml_doc = nil
    end

    def name
      return @properties[:zip_entry].name
    end

    def content
      if @xml_doc.nil?
        return @content
      end
      return UMPTG::XMLUtil.doc_to_xml(@xml_doc)
    end

    def xml_doc
      if @xml_doc.nil?
        # Create the XML tree.
        begin
          @xml_doc = Nokogiri::XML(content, nil, 'UTF-8')
        rescue Exception => e
          raise e.message
        end
      end
      return @xml_doc
    end

    def get_input_stream
      return @properties[:zip_entry].get_input_stream
    end

    def name_is_directory?
      return @properties[:zip_entry].name_is_directory?
    end

    def write(output_stream, args = {})
      raise "Error: missing output stream" if output_stream.nil?

      compression_method = args[:compression_method]
      compression_method = Zip::Entry::DEFLATED if compression_method.nil?

      output_stream.put_next_entry(@properties[:zip_entry].name, nil, nil, compression_method)
      output_stream.write(content)
=begin
      if @properties[:content].nil?
        output_stream.write(@properties[:zip_entry].get_input_stream.read)
      else
        output_stream.write(@properties[:content])
      end
=end
    end
  end
end
