module UMPTG::EPUB

  class Entry < UMPTG::Object
    attr_accessor :name, :content
    attr_reader :id

    def initialize(args = {})
      super(args)

      @name = args[:entry_name]
      raise "entry name is required" if @name.nil? or @name.strip.empty?

      @content = args[:entry_content]
      @content = "" if @content.nil?

      @id = @name.gsub(/\/[ ]+/, '_')
    end

    def write(output_stream, args = {})
      raise "Error: missing output stream" if output_stream.nil?

      a = args.clone
      a[:entry_name] = @name
      a[:entry_content] = @content
      Entry.write(output_stream, a)
    end

    def self.write(output_stream, args = {})
      raise "missing output stream" if output_stream.nil?

      nme = args[:entry_name]
      raise "missing entry name" if nme.nil? or nme.strip.empty?

      content = args[:entry_content]
      content = "" if content.nil?

      compression_method = args[:compression_method]
      compression_method = Zip::Entry::DEFLATED if compression_method.nil?

      output_stream.put_next_entry(nme, nil, nil, compression_method)
      output_stream.write(content)
    end
  end
end
