module UMPTG::EPUB::Archive

  require 'zip/filesystem'
  require 'find'

  class Files < UMPTG::Object
    attr_reader :epub

    def initialize(args = {})
      super(args)

      @epub = args[:epub]
      @entries = []
      @name2entry = {}
      @container_entry = nil
      @container = nil
    end

    def load(args = {})
      epub_path = args[:epub_path] || ""

      if epub_path.empty?
        load_scratch(args)
        # Load a scratch EPUB
        add(
              entry_name: "mimetype",
              entry_content: "application/epub+zip"
            )
        @container_entry = add(
              entry_name: UMPTG::EPUB::Archive::MetaInf::Container.DEFAULT_PATH,
              entry_content: UMPTG::EPUB::Archive::MetaInf::Container.DEFAULT_XML
            )
        add(
              entry_name: UMPTG::EPUB::Archive::OEBPS::Rendition.DEFAULT_PATH,
              entry_content: Rendition.DEFAULT_XML
            )
        add(
              entry_name: UMPTG::EPUB::Archive::OEBPS::Navigation.DEFAULT_PATH,
              entry_content: Navigation.DEFAULT_XML
            )
        return
      end

      # Load a path
      epub_path = File.expand_path(epub_path)
      raise "invalid file path #{epub_path}" unless File.exist?(epub_path)

      if File.directory?(epub_path)
        # Load directory contents
        Find.find(epub_path) do |path|
          next if File.directory?(path)

          add(
              entry_name: path.delete_prefix(epub_path + File::SEPARATOR),
              entry_content: File.open(path, "rb") {|f| f.read }
              )
        end
      else
        # Load file contents
        Zip::File.open(epub_path) do |zip|
          zip.entries.each do |zip_entry|
            next if zip_entry.file_type_is?(:directory)

            add(
                entry_name: zip_entry.name,
                entry_content: zip_entry.get_input_stream.read
                )
          end
        end
      end

      @container_entry = @name2entry[UMPTG::EPUB::Archive::MetaInf::Container.DEFAULT_PATH]
      raise "unable to find #{container_path}" if @container_entry.nil?
    end

    def container()
      @container = UMPTG::EPUB::Archive::MetaInf::Container.new(
              epub: @epub,
              file_entry: @container_entry
            ) if @container.nil?
      return @container
    end

    def save(args = {})
      epub_file = args[:epub_file]
      raise "EPUB path must be specified" if epub_file.nil? or epub_file.strip.empty?

      Zip::OutputStream.open(epub_file) do |zos|
        # Make the mimetype the first item
        FileEntry.write(
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
      e_list = []

      entry_name = args[:entry_name]
      e_list << @name2entry[entry_name] unless entry_name.nil? or entry_name.strip.empty?

      media_type = args[:media_type]
      e_list += @entries.select {|e| e.media_type == media_type }
      return e_list
    end

    def add(args = {})
      entry = find(args).first
      if entry.nil?
        a = args.clone
        a[:files] = self
        entry = FileEntry.new(a)
        @entries << entry
        @name2entry[entry.name] = entry
      else
        entry.replace(entry_content: args[:entry_content])
      end
      return entry
    end

    def self.MK_PATH(file_entry, entry_name)
      m = File.expand_path(file_entry.name)
      n = File.expand_path(entry_name)
      return n.delete_prefix(File.dirname(m)+"/")
    end

    def self.MK_ID(val, prefix = "item")
      raise "missing ID value" if val.nil? or val.strip.empty?
      return prefix + "_" + val.gsub(/[ \/\.\,\-]+/, '_')
    end
  end
end
