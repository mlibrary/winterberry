module UMPTG::EPUB

  require 'zip/filesystem'
  require 'nokogiri'

  class Archive < UMPTG::Object

    def initialize(args = {})
      super(args)

      @entries = []
      @renditions = {}

      a = args.clone
      case
      when args.key?(:epub_file)
        load_file(a)
      else
        load(a)
      end
    end

    def add_entry(args = {})
      entry = Entry.new(args)
      @entries << entry
    end

    def save(args = {})
      epub_file = args[:epub_file]
      raise "EPUB path must be specified" if epub_file.nil? or epub_file.strip.empty?

      Zip::OutputStream.open(epub_file) do |zos|
        # Make the mimetype the first item
        Entry.write(
            zos,
            entry_name: "mimetype",
            entry_content: "application/epub+zip",
            compression_method: Zip::Entry::STORED
          )

        # Write the META-INF/container.xml
        container_doc = Nokogiri::XML(CONTAINER_XML)
        rf = container_doc.xpath("//*[local-name()='rootfiles']").first
        raise "unable to locate rootfiles" if rf.nil?
        @renditions.keys.each {|k| rf.add_child(sprintf(ROOTFILE_XML, File.join("OEBPS", k + ".opf"))) }
        Entry.write(
            zos,
            entry_name: File.join("META-INF", "container.xml"),
            entry_content: container_doc.to_xml
          )

        # Write the renditions
        @renditions.values.each {|rend| rend.write(zos) }
      end
    end

    private

    def load(args = {})
      n = args[:rendition_name]
      if n.nil? or n.strip.empty?
        cnt = @renditions.count
        n = cnt == 0 ? "content" : "content_" + @renditions.count.to_s.rjust(3, '0')
      end
      args[:rendition_name] = n

      rendition = Rendition.new(args)
      @renditions[rendition.name] = Rendition.new(args)
    end

    def load_file(args = {})
      epub_file = args[:epub_file]
      raise "missing value for EPUB file" if epub_file.nil? or epub_file.strip.empty?
      raise "invalid file path #{@epub_file}" unless File.exist?(epub_file)

      Zip::File.open(epub_file) do |zip|
        zip.entries.each do |zip_entry|
          next if zip_entry.file_type_is?(:directory)
          @entries << Entry.new(
                entry_name: zip_entry.name,
                entry_content: zip_entry.get_input_stream.read
              )
        end
      end

      entry = find_entry(File.join("META-INF", "container.xml"))
      raise "unable to find container.xml" if entry.nil?

      container_doc = Nokogiri::XML(entry.content)
      rf_list = container_doc.xpath("//*[local-name()='rootfile' and media-type='application/oebps-package+xml' and @full-path]")
      raise "unable to locate rootfiles" if rf.empty?

      rf_list.each do |rf|
        rendition_name = File.basename(rf['full-path'], ".*")
        rendition = Rendition.new(
              rendition_name: rendition_name,
              rendition_content: rf.content
            )
        @renditions[rendition.name] = rendition
      end
  end
end