module UMPTG::EPUB

  require 'fileutils'
  require 'zip'
  require 'tempfile'

  class Migrator
    def self.migrate(args = {})
      case
      when args.key?(:epub)
        epub = args[:epub]
      when args.key?(:epub_file)
        epub_file = args[:epub_file]
        epub = Archive.new(epub_file: epub_file)
      else
        raise "Error: :epub or :epub_file not specified."
      end

      replace_set = {}
      add_set = []
      epub.renditions.each do |rendition|
        puts "Processing file #{rendition.opf_item.name}"

        srcfile = Tempfile.new(File.basename(rendition.opf_item.name))
        #puts srcfile.path
        srcfile.write(rendition.opf_item.get_input_stream.read)
        srcfile.close
        destpath = File.join(File.dirname(srcfile.path), File.basename(rendition.opf_item.name))
        UMPTG::XSLT.transform(
              xslpath: File.join(UMPTG::XSLT.XSL_DIR, "update_opf.xsl"),
              srcpath: srcfile.path,
              destpath: destpath
          )
        entry = Zip::Entry.new
        entry.name = rendition.opf_item.name
        entry.comment = File.read(destpath)
        replace_set[entry.name] = entry
        # rendition.replace_content(rendition.opf_item.name, File.read(destpath))

        nav_items = rendition.nav_items
        puts "nav_items: #{nav_items.count}"
        if nav_items.empty?
          ncx_item_list = rendition.ncx_items
          if ncx_item_list.empty?
            puts "Warning: no NCX item found."
          else
            ncx_item = ncx_item_list.first
            ncx_href = ncx_item["href"]
            ncx_entry_list = epub.epub.glob(File.join('*', ncx_href))
            if ncx_entry_list.empty?
              puts "Warning: no NCX file found."
            else
              ncx_entry = ncx_entry_list.first
              #puts ncx_entry.name

              srcfile = Tempfile.new(File.basename(ncx_entry.name))
              #puts srcfile.path
              srcfile.write(ncx_entry.get_input_stream.read)
              srcfile.close

              nn = epub.epub.glob(File.join("**", "toc.xhtml"))
              puts "nn: #{nn.first}"

              dpath = File.dirname(ncx_entry.name)
              nav_base = "toc_nav.xhtml"
              nav_file = File.join(dpath, nav_base) unless dpath.empty? or dpath == '.'
              nav_file = nav_base if dpath.empty? or dpath == '.'
              #puts nav_file

              destpath = File.join(File.dirname(srcfile.path), nav_base)
              #puts destpath
              UMPTG::XSLT.transform(
                    xslpath: File.join(UMPTG::XSLT.XSL_DIR, "ncx2xhtml.xsl"),
                    srcpath: srcfile.path,
                    destpath: destpath
                )
              entry = Zip::Entry.new
              entry.name = nav_file
              entry.comment = File.read(destpath)
              add_set << entry
              # rendition.add_entry(nav_file, File.read(destpath)

              destpath = File.join(File.dirname(srcfile.path), File.basename(srcfile.path))
              UMPTG::XSLT.transform(
                    xslpath: File.join(UMPTG::XSLT.XSL_DIR, "update_ncx.xsl"),
                    srcpath: srcfile.path,
                    destpath: destpath
                )
              entry = Zip::Entry.new
              entry.name = ncx_entry.name
              entry.comment = File.read(destpath)
              replace_set[entry.name] = entry
              # rendition.replace(ncx_entry.name, File.read(destpath))

=begin
              manifest_list = doc.xpath("//*[local-name()='manifest']")
              if manifest_list.empty?
                puts "Warning: no manifest in new OPF."
              else
                manifest = manifest_list.first
                manifest.prepend_child("<item id=\"toc\" href=\"#{nav_file}\" properties=\"nav\" media-type=\"application/xhtml+xml\"")

                entry = Zip::Entry.new
                entry.name = nav_file
                entry.comment = File.read(destpath)
                add_set << entry
              end
=end
            end
          end
        end

        rendition.spine_items.each do |spine_item|

          puts "Processing file #{spine_item.name}"
          STDOUT.flush

          # Create the XML tree.
          srcfile = Tempfile.new(File.basename(spine_item.name))
          #puts srcfile.path
          srcfile.write(spine_item.get_input_stream.read)
          srcfile.close
          destpath = File.join(File.dirname(srcfile.path), File.basename(spine_item.name))
          UMPTG::XSLT.transform(
                xslpath: File.join(UMPTG::XSLT.XSL_DIR, "update_xhtml.xsl"),
                srcpath: srcfile.path,
                destpath: destpath
            )
          new_entry_name = File.join(File.dirname(spine_item.name), File.basename(spine_item.name, ".*") + ".xhtml")
          entry = Zip::Entry.new
          entry.name = new_entry_name
          entry.comment = File.read(destpath)
          #add_set << entry
          replace_set[spine_item.name] = entry
          # rendition.add(new_entry_name, File.read(destpath))
          # rendition.remove(spine_item.name)
        end
      end

      output_epub_file = File.join(File.dirname(epub_file), File.basename(epub_file, ".*") + "_migrate.epub")
      if File.exist?(output_epub_file)
        FileUtils.remove(output_epub_file)
      end

      # epub.save(path: output_epub_file)
      Zip::OutputStream.open(output_epub_file) do |zos|
        # Make the mimetype the first item
        input_entry_list = epub.epub.glob("mimetype")
        mimetype_entry = input_entry_list.first
        zos.put_next_entry(mimetype_entry.name, nil, nil, Zip::Entry::STORED)
        zos.write(mimetype_entry.get_input_stream.read)

        # Replace existing entries.
        epub.all_items.each do |input_entry|
          unless input_entry.name_is_directory? or input_entry.name == 'mimetype'
            if replace_set.key?(input_entry.name)
              puts "Replacing file #{input_entry.name}"
              new_entry = replace_set[input_entry.name]
              zos.put_next_entry(new_entry.name)
              zos.write new_entry.comment
            else
              puts "Using file #{input_entry.name}"
              zos.put_next_entry(input_entry.name)
              zos.write input_entry.get_input_stream.read
            end
          end
        end

        add_set.each do |input_entry|
          puts "Adding file #{input_entry.name}"
          zos.put_next_entry(input_entry.name)
          zos.write input_entry.comment
        end
      end

      puts "Wrote #{output_epub_file}"
    end
  end
end
