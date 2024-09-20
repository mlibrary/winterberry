module UMPTG::EPUB

  require 'zip/filesystem'

  class Archive < UMPTG::Object

    CONTAINER_XML = <<-CONXML
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
<rootfiles>
<rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
</rootfiles>
</container>
    CONXML

    OPF_TEMPLATE = <<-PKG
<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="pub-id" dir="ltr" xml:lang="en">
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf">
<dc:identifier id="pub-id">pubid</dc:identifier>
<dc:title>Ebook Title</dc:title>
<dc:language>en</dc:language>
</metadata>
<manifest/>
<spine/>
</package>
    PKG

    OPF_TEMPLATE_OLD = <<-PKG
<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="pub-id" dir="ltr" xml:lang="en">
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf">
<dc:identifier id="pub-id">pubid</dc:identifier>
<dc:title>Ebook Title</dc:title>
<dc:language>en</dc:language>
</metadata>
<manifest>
<item id="nav" properties="nav" href="navigation.xhtml" media-type="application/xhtml+xml"/>
</manifest>
<spine></spine>
</package>
    PKG

    def initialize(args = {})
      super(args)

      @entries = []
      @name2entry = {}
      @container_entry = nil

      load(args)
    end

    def load(args = {})
      epub_file = args[:epub_file]
      epub_file = (epub_file.nil? or epub_file.strip.empty?) ? "" : epub_file.strip

      container_path = File.join("META-INF", "container.xml")
      if epub_file.empty?
        add(
              entry_name: "mimetype",
              entry_content: "application/epub+zip"
            )
        @container_entry = add(
              entry_name: container_path,
              entry_content: CONTAINER_XML
            )
        add(
              entry_name: File.join("OEBPS", "content.opf"),
              entry_content: OPF_TEMPLATE
            )
      else
        raise "invalid file path #{epub_file}" unless File.exist?(epub_file)

        Zip::File.open(epub_file) do |zip|
          zip.entries.each do |zip_entry|
            next if zip_entry.file_type_is?(:directory)
            add(
                entry_name: zip_entry.name,
                entry_content: zip_entry.get_input_stream.read
                )
          end
        end

        @container_entry = name2entry[container_path]
        raise "unable to find #{container_path}" if entry.nil?
      end
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

        # Write out rest of entries.
        opf_files = renditions.collect {|r| r.name }
        @entries.each do |entry|
          next if entry.name == "mimetype"

          unless opf_files.include?(entry.name)
            entry.write(zos)
            next
          end

          modified_date = Time.now.strftime("%Y-%m-%dT%H:%M:%S") + "Z"
          doc = entry.document.clone
          Rendition.add_modified(
                doc,
                value: modified_date
                )
          Entry.write(
              zos,
              entry_name: entry.name,
              entry_content: doc.to_xml
            )
        end
      end
    end

    def renditions(args = {})
      rf_list = @container_entry.document.xpath("//*[local-name()='rootfile' and @media-type='application/oebps-package+xml' and @full-path]")
      raise "unable to locate rootfiles" if rf_list.empty?

      return rf_list.collect {|r| @name2entry[r['full-path']] }
    end

    def add(args = {})
      entry_name = args[:entry_name]
      raise "missing entry name" if entry_name.nil? or entry_name.strip.empty?
      entry_name = entry_name.strip

      entry_content = args[:entry_content]

      if @name2entry.key?(entry_name)
        entry = @name2entry[entry_name]
        entry.replace(entry_content: entry_content)
      else
        entry = Entry.new(
                entry_name: entry_name,
                entry_content: entry_content,
                archive: self
              )
        @entries << entry
        @name2entry[entry_name] = entry
      end
      return entry
    end

    def find(args = {})
      entry_name = args[:entry_name]
      return @name2entry[entry_name] unless entry_name.nil? or entry_name.strip.empty?
    end
  end
end
