module UMPTG::EPUB

  require 'zip/filesystem'

  class Archive < UMPTG::Object
    attr_reader :epub

    def initialize(args = {})
      super(args)

      @epub = args[:epub]
      @entries = []
      @name2entry = {}
      @container_entry = nil
      @container = nil

      load(args)
    end

    def load(args = {})
      epub_file = args[:epub_file]
      epub_file = (epub_file.nil? or epub_file.strip.empty?) ? "" : epub_file.strip

      if epub_file.empty?
        add(
              entry_name: "mimetype",
              entry_content: "application/epub+zip"
            )
        @container_entry = add(
              entry_name: Container.DEFAULT_PATH,
              entry_content: Container.DEFAULT_XML
            )
        add(
              entry_name: Rendition.DEFAULT_PATH,
              entry_content: Rendition.DEFAULT_XML,
              opf: true
            )
        add(
              entry_name: Navigation.DEFAULT_PATH,
              entry_content: Navigation.DEFAULT_XML
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

        @container_entry = name2entry[Container.CONTAINER_PATH]
        raise "unable to find #{container_path}" if entry.nil?
      end

    end

    def container()
      @container = Container.new(
              epub: @epub,
              archive_entry: @container_entry
            ) if @container.nil?
      return @container
    end

    def save(args = {})
      epub_file = args[:epub_file]
      raise "EPUB path must be specified" if epub_file.nil? or epub_file.strip.empty?

      Zip::OutputStream.open(epub_file) do |zos|
        # Make the mimetype the first item
        ArchiveEntry.write(
            zos,
            entry_name: "mimetype",
            entry_content: "application/epub+zip",
            compression_method: Zip::Entry::STORED
          )

        # Write out rest of entries.
        @entries.each do |entry|
          entry.write(zos) unless entry.name == "mimetype"
        end
      end
    end

    def find(args = {})
      entry_name = args[:entry_name]
      return @name2entry[entry_name] unless entry_name.nil? or entry_name.strip.empty?
    end

    def add(args = {})
      entry = find(args)
      if entry.nil?
        is_opf = args[:opf]
        is_opf = false if is_opf.nil?
        a = args.clone
        a[:archive] = self
        entry = is_opf ? OPFArchiveEntry.new(a) : ArchiveEntry.new(a)
        @entries << entry
        @name2entry[entry.name] = entry
      else
        entry.replace(entry_content: entry_content)
      end
      return entry
    end

    def self.MK_PATH(archive_entry, entry_name)
      m = File.expand_path(archive_entry.name)
      n = File.expand_path(entry_name)
      return n.delete_prefix(File.dirname(m)+"/")
    end

    def self.MK_ID(val, prefix = "item")
      raise "missing ID value" if val.nil? or val.strip.empty?
      return prefix + "_" + val.gsub(/[ \/\.\,\-]+/, '_')
    end
  end
end
