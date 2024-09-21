module UMPTG::EPUB
  require 'nokogiri'
  require 'mime/types'

  class Entry < UMPTG::Object
    attr_accessor :name, :content, :media_type
    attr_reader :archive

    def initialize(args = {})
      super(args)

      @name = args[:entry_name]
      raise "entry name is required" if @name.nil? or @name.strip.empty?

      @content = args[:entry_content]
      @content = "" if @content.nil?

      @media_type = args[:entry_mediatype]
      @media_type = UMPTG::EPUB::Entry.media_type(entry_name: @name) if @media_type.nil?

      @archive = args[:archive]
      @document = nil
    end

    def document
      @document = Nokogiri::XML(@content) if @document.nil?
      return @document
    end

    def replace(args = {})
      entry_content = args[:entry_content]
      entry_content = "" if entry_content.nil?
      @content = entry_content
      @document = nil
    end

    def write(output_stream, args = {})
      raise "Error: missing output stream" if output_stream.nil?

      a = args.clone
      a[:entry_name] = @name
      a[:entry_content] = @document.nil? ? @content : @document.to_xml
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

    def self.media_type(args = {})
      entry_name = args[:entry_name]
      return if entry_name.nil?

      mt_list = MIME::Types.type_for(File.extname(entry_name.strip))
      return  mt_list.empty? ? nil : mt_list.first
    end
  end
end
