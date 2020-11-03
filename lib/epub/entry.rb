module UMPTG::EPUB

  require 'zip'

  class Entry
    attr_accessor :content
    
    def initialize(args = {})
      @content = args[:content] if args.key?(:content)
      @zip_entry = args[:zip_entry] if args.key?(:zip_entry)
    end

    def name
      return @zip_entry.name
    end

    def get_input_stream
      return @zip_entry.get_input_stream
    end

    def name_is_directory?
      return @zip_entry.name_is_directory?
    end

    def write(output_stream, args = {})
      raise "Error: missing output stream" if output_stream.nil?

      compression_method = args[:compression_method]
      compression_method = Zip::Entry::DEFLATED if compression_method.nil?

      output_stream.put_next_entry(@zip_entry.name, nil, nil, compression_method)

      if @content.nil?
        output_stream.write(@zip_entry.get_input_stream.read)
      else
        output_stream.write(@content)
      end
    end
  end
end
