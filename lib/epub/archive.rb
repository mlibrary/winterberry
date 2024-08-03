module UMPTG::EPUB

  require 'zip'

  class Archive < UMPTG::Object
    attr_reader :epub_file, :modified

    OPF_ENTRY_NAME = "OEBPS/content.opf"

    CONTAINER_XML =  <<-CONXML
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
<rootfiles>
<rootfile full-path="%s" media-type="application/oebps-package+xml"/>
</rootfiles>
</container>
    CONXML

    NAVIGATION_XML = <<-NAVXML
<?xml version="1.0"?>
<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
<head>
<meta content="initial-scale=1.0,maximum-scale=5.0" name="viewport"/>
<title>Navigation</title>
<link href="default.css" rel="stylesheet" type="text/css"/>
</head>
<body>
  <nav id="toc" role="doc-toc" epub:type="toc" aria-labelledby="ncx-head">
    <h1 id="ncx-head">Contents</h1>
    <ol></ol>
  </nav>
  <nav id="landmarks" epub:type="landmarks">
    <h2>Guide</h2>
    <ol></ol>
  </nav>
  </body>
</html>
    NAVXML

    def initialize(args = {})
      super(args)

      @renditions = {}
      @name2entry = {}
      @nav_doc = nil

      case
      when @properties.key?(:epub_file)
        load(epub_file: @properties[:epub_file])
      else
        rend = UMPTG::EPUB::Rendition.new(name: OPF_ENTRY_NAME)
        @renditions[OPF_ENTRY_NAME] = rend
        @modified = false
        add(
            entry_name: "mimetype",
            entry_content: "application/epub+zip"
          )
        add(
            entry_name: "META-INF/container.xml",
            entry_content: sprintf(CONTAINER_XML, OPF_ENTRY_NAME)
          )
        add(
            entry_name: "OEBPS/toc.xhtml",
            entry_content: NAVIGATION_XML,
            media_type: "application/xhtml+xml",
            properties: "nav"
          )
      end
    end

    def entry(name)
      return @name2entry[name.delete_prefix("./")]
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

        entry_name = entry_name.delete_prefix("./")
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

      epub_manifest_node = opf_doc.xpath("//*[local-name()='manifest']").first
      raise "no manifest found for #{epub_file}" if epub_manifest_node.nil?

      if args.key?(:media_type)
        media_type = args[:media_type]

        item_id = "item#{File.basename(entry.name).gsub(/[. ]+/,'_')}"
        item_node = epub_manifest_node.xpath("./*[local-name()='item' and @id='#{item_id}']").first

        if item_node.nil?
          ename = entry.name.delete_prefix(File.dirname(opf_name) + "/")
          item_node = opf_doc.parse(
              "<item id=\"item#{File.basename(entry.name).gsub(/[. ]+/,'_')}\" href=\"#{ename}\"/>"
            ).first
          epub_manifest_node.add_child(item_node)
        end

        item_node["media-type"] = media_type

        if args.key?(:spine_loc) and !media_type.start_with?("image/")
          spine_loc = args[:spine_loc]

          epub_spine_node = opf_doc.xpath("//*[local-name()='spine']").first
          raise "no spine found for #{epub_file}" if epub_spine_node.nil?

          new_spine_markup = "<itemref idref=\"#{item_node['id']}\"/>"

          itemref_list = epub_spine_node.xpath("./*[local-name()='itemref']")
          if itemref_list.empty? or spine_loc == -1
            epub_spine_node.add_child(new_spine_markup)
          else
            case spine_loc
            when 0
              n = itemref_list[0]
              n.before(new_spine_markup)
            else
              n = itemref_list[spine_loc]
              n.before(new_spine_markup)
            end
          end
        end

        properties = args[:properties]
        unless properties.nil?
          p = properties.strip
          item_node["properties"] = p unless p.empty?
        end

        add(
            entry_name: opf_name,
            entry_content: UMPTG::XML.doc_to_xml(opf_doc)
          )

        if args[:toc_title]
          toc_title = args[:toc_title].strip

          add_navigation(
              entry: entry,
              toc_title: toc_title,
              epub_type: args[:epub_type]
            )
        end

      end

      return entry
    end

    def add_navigation(args = {})
      entry = args[:entry]
      toc_title = args[:toc_title]
      epub_type = args[:epub_type]

      nav_doc = navigation_doc(args)
      return if nav_doc.nil?

      add_entry = false
      unless toc_title.nil? or toc_title.strip.empty?
        toc_node = nav_doc.xpath("//*[local-name()='nav' and @epub:type='toc']/*[local-name()='ol']").first
        unless toc_node.nil?
          markup = "<li id=\"toc_#{toc_node.children.count}\"><a href=\"#{File.basename(entry.name)}\">#{toc_title}</a></li>"
          toc_node.add_child(markup)
          add_entry = true
        end
      end

      unless epub_type.nil? or epub_type.strip.empty?
        lm_node = nav_doc.xpath("//*[local-name()='nav' and @epub:type='landmarks']/*[local-name()='ol']").first
        unless lm_node.nil?
          markup = "<li><a href=\"#{File.basename(entry.name)}\" epub:type=\"#{epub_type}\">#{toc_title}</a></li>"
          lm_node.add_child(markup)
          add_entry = true
        end
      end

      if add_entry
        add(
            entry_name: navigation.first.name,
            entry_content: UMPTG::XML.doc_to_xml(nav_doc)
          )
      end
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

    def metadata(args = {})
      label, rend = rendition(args)
      return rend.metadata
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

    def navigation_doc(args = {})
      if @nav_doc.nil?
        nav_entry = navigation(args).first
        @nav_doc = Nokogiri::XML::Document.parse(nav_entry.content) \
            unless nav_entry.nil?
      end
      return @nav_doc
    end

    def ncx(args = {})
      label, rend = rendition(args)
      return item_list(rend.ncx_items, File.dirname(label))
    end

    def css(args = {})
      label, rend = rendition(args)
      return item_list(rend.css_items, File.dirname(label))
    end

    def cover(args = {})
      label, rend = rendition(args)
      cover_name = rend.cover_name
      return entry(File.join(File.dirname(label), cover_name))
    end

    def xhtml(args = {})
      label, rend = rendition(args)
      xhtml_list = rend.xhtml_items.collect do |item|
        entry(File.join(File.dirname(label), item['href']))
      end
      return xhtml_list
    end

    def load(args = {})
      @epub_file = args[:epub_file]
      @modified = false

      raise "Error: missing file path" if @epub_file.strip.empty?
      raise "Error: invalid file path #{@epub_file}" unless File.exist?(@epub_file)

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
          rendition.manifest.each do |n|
            e = entry(File.join(File.dirname(rendition.name), n['href']))
            unless e.nil?
              e.type = n['media-type']
              e.props = n['properties']
            end
          end
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
