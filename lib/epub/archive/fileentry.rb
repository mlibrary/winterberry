module UMPTG::EPUB::Archive
  require 'nokogiri'
  require 'mime/types'

  class FileEntry < UMPTG::Object
    attr_accessor :name, :content, :media_type
    attr_reader :files

    OPF_MEDIA_TYPE = "application/oebps-package+xml"

    def initialize(args = {})
      super(args)

      @name = args[:entry_name]
      raise "entry name is required" if @name.nil? or @name.strip.empty?

      @content = args[:entry_content]
      @content = "" if @content.nil?

      @media_type = args[:entry_mediatype]
      @media_type = FileEntry.media_type(entry_name: @name) if @media_type.nil?

      @files = args[:files]
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

    def rename(args = {})
      entry_name = args[:entry_name] || ""
      @name = entry_name unless entry_name.empty?
    end

    def write(output_stream, args = {})
      raise "Error: missing output stream" if output_stream.nil?

      a = args.clone
      a[:entry_name] = @name
      a[:entry_content] = @document.nil? ? @content : @document.to_xml
      FileEntry.write(output_stream, a)
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
      return nil if entry_name.nil?

      mt_list = MIME::Types.type_for(File.extname(entry_name.strip))
      return mt_list.empty? ? nil : mt_list.first
    end

    def self.OPF_MEDIA_TYPE
      return OPF_MEDIA_TYPE
    end
  end
end
