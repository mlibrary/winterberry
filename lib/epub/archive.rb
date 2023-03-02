module UMPTG::EPUB

  require 'zip'

  class Archive < UMPTG::Object
    attr_reader :epub_file, :modified

    def initialize(args = {})
      super(args)

      @renditions = {}
      @name2entry = {}

      case
      when @properties.key?(:epub_file)
        load(epub_file: @properties[:epub_file])
      else
        label = "OEBPS/content.opf"
        rend = UMPTG::EPUB::Rendition.new(name: label)
        @renditions[label] = rend
        @modified = false
      end
    end

    def entry(name)
      return @name2entry[name]
    end

    def entries
      return @name2entry.values
    end

    def renditions
      return @renditions.values
    end

    def add(args = {})
      case
      when args.key?(:zip_entry)
        zip_entry = args[:zip_entry]
        entry = Entry.new(zip_entry: zip_entry)
      when args.key?(:entry_name)
        entry_name = args[:entry_name]
        raise "Error: empty entry name" if entry_name.strip.empty?
        entry_content = args[:entry_content]
        raise "Error: missing entry content" if entry_content.nil?

        if @name2entry.key?(entry_name)
          entry = @name2entry[entry_name]
          if entry_content != entry.content
            entry.content = entry_content
            entry.modified = true
            @modified = true
          end
        else
          zip_entry = Zip::Entry.new
          zip_entry.name = entry_name
          entry = Entry.new(zip_entry: zip_entry, content: entry_content)
          entry.modified = true
          @modified = true
        end
      end

      @name2entry[entry.name] = entry
    end

    def remove(args = {})
      entry_name = args[:entry_name]
      raise "Error: empty entry name" if entry_name.strip.empty?

      @name2entry.delete(entry_name)
      @modified = true
    end

    def save(args = {})
      efile = args[:epub_file]
      efile = @epub_file if efile.nil? or efile.empty?
      raise "Error: missing EPUB file path" if efile.nil? or efile.empty?

      Zip::OutputStream.open(efile) do |zos|
        # Make the mimetype the first item
        mimetype_entry = @name2entry["mimetype"]
        raise "Error: mimetype file missing" if mimetype_entry.nil?

        mimetype_entry.write(zos, compression_method: Zip::Entry::STORED)

        @name2entry.values.each do |entry|
          unless entry.name_is_directory? or entry.name == 'mimetype'
            entry.write(zos)
          end
        end
      end
    end

    def version(args = {})
      label, rend = rendition(args)
      rend.version(args[:version]) if args.key?(:version)
      return rend.version
    end

    def opf(args = {})
      label, rend = rendition(args)
      return @name2entry[label]
    end

    def opf_name(args = {})
      label, rend = rendition(args)
      return label
    end

    def opf_doc(args = {})
      label, rend = rendition(args)
      return rend.opf_doc
    end

    def manifest(args = {})
      label, rend = rendition(args)
      return item_list(rend.manifest, File.dirname(label))
    end

    def spine(args = {})
      label, rend = rendition(args)
      return item_list(rend.spine, File.dirname(label))
    end

    def navigation(args = {})
      label, rend = rendition(args)
      return item_list(rend.nav_items, File.dirname(label))
    end

    def ncx(args = {})
      label, rend = rendition(args)
      return item_list(rend.ncx_items, File.dirname(label))
    end

    def css(args = {})
      label, rend = rendition(args)
      return item_list(rend.css_items, File.dirname(label))
    end

    def load(args = {})
      @epub_file = args[:epub_file]
      @modified = false

      raise "Error: missing file path" if @epub_file.strip.empty?
      raise "Error: invalid file path" unless File.exist?(@epub_file)

      fragment_processor = UMPTG::Fragment::Processor.new
      fragment_selector = UMPTG::Fragment::ContainerSelector.new

      Zip::File.open(@epub_file) do |zip|
        zip.entries.each do |zip_entry|
          next if zip_entry.file_type_is?(:directory)
          @name2entry[zip_entry.name] = Entry.new(zip_entry: zip_entry)
        end

        container = @name2entry[File.join("META-INF", "container.xml")]
        raise "Error: missing container.xml" if container.nil?

        fragment_selector.containers = [ 'rootfile' ]
        fragment_list = fragment_processor.process(
              :content => container.get_input_stream.read,
              :selector => fragment_selector
            )
        raise "Error: missing rootfile" if fragment_list.empty?

        fragment_list.each do |fragment|
          root_elem = fragment.node
          opf_file = root_elem['full-path']
          opf_entry = @name2entry[opf_file]
          raise "Error: invalid OPF path" if opf_entry.nil?

          rendition = Rendition.new(
                      name: opf_entry.name,
                      content: opf_entry.get_input_stream.read
                    )
          @renditions[opf_entry.name] = rendition
        end
      end
    end

    private

    def rendition(args = {})
      case
      when args.key?(:rendition)
        rend = args[:rendition]
        label = rend.name unless rend.name.nil? or rend.name.strip.empty?
        label = "default" if rend.name.nil? or rend.name.strip.empty?
      when args.key?(:rendition_name)
        label = args[:rendition_name]
        rend = @renditions[label]
        raise "Error: invalid rendition #{label}" if rend.nil?
      else
        label = @renditions.keys[0]
        rend = @renditions.values[0]
      end
      return label, rend
    end

    def item_list(list, dpath)
      items = []
      list.each do |item|
        href = File.expand_path(item['href'], dpath)
        href.delete_prefix!(Dir.pwd + File::SEPARATOR)
        item = @name2entry[href]
        puts "href: #{href}" if item.nil?
        items << item
      end
      return items
    end
  end
end
