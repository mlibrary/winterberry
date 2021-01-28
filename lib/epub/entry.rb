module UMPTG::EPUB

  require 'zip'

  class Entry < UMPTG::Object
    attr_accessor :content
    
    def initialize(args = {})
      super(args)

      raise "Error: missing entry content" if @properties[:content].nil? and @properties[:zip_entry].nil?
    end

    def name
      return @properties[:zip_entry].name
    end

    def xml_doc
      # Create the XML tree.
      content = @properties[:zip_entry].get_input_stream.read
      begin
        xml_doc = Nokogiri::XML(content, nil, 'UTF-8')
      rescue Exception => e
        raise e.message
      end
      return xml_doc
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

      if @properties[:content].nil?
        output_stream.write(@properties[:zip_entry].get_input_stream.read)
      else
        output_stream.write(@properties[:content])
      end
    end
  end
end
