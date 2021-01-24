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
        puts "Processing file #{rendition.name}"

        epub.version(rendition: rendition.name, version: "3.0")

        srcfile = Tempfile.new(File.basename(rendition.name))
        srcfile.write(rendition.opf_to_s)
        srcfile.close
        destpath = File.join(File.dirname(srcfile.path), File.basename(rendition.name))
        UMPTG::XSLT.transform(
              xslpath: File.join(UMPTG::XSLT.XSL_DIR, "update_opf.xsl"),
              srcpath: srcfile.path,
              destpath: destpath
          )
        epub.add(entry_name: rendition.name, entry_content: File.read(destpath))

        nav_items = epub.navigation(rendition: rendition.name)
        puts "nav_items: #{nav_items.count}"
        if nav_items.empty?
          ncx_item_list = epub.ncx(rendition: rendition.name)
          if ncx_item_list.empty?
            puts "Warning: no NCX item found."
          else
            ncx_entry = ncx_item_list.first
            ncx_href = ncx_entry.name
            srcfile = Tempfile.new(File.basename(ncx_entry.name))
            srcfile.write(ncx_entry.get_input_stream.read)
            srcfile.close

            dpath = File.dirname(ncx_entry.name)
            nav_base = "toc_nav.xhtml"
            nav_file = File.join(dpath, nav_base) unless dpath.empty? or dpath == '.'
            nav_file = nav_base if dpath.empty? or dpath == '.'
            destpath = File.join(File.dirname(srcfile.path), nav_base)
            UMPTG::XSLT.transform(
                  xslpath: File.join(UMPTG::XSLT.XSL_DIR, "ncx2xhtml.xsl"),
                  srcpath: srcfile.path,
                  destpath: destpath
              )
            epub.add(entry_name: nav_file, entry_content: File.read(destpath))

            destpath = File.join(File.dirname(srcfile.path), File.basename(srcfile.path))
            UMPTG::XSLT.transform(
                  xslpath: File.join(UMPTG::XSLT.XSL_DIR, "update_ncx.xsl"),
                  srcpath: srcfile.path,
                  destpath: destpath
              )
            epub.add(entry_name: ncx_entry.name, entry_content: File.read(destpath))
          end
        end

        spine_items = epub.spine(rendition: rendition.name)
        spine_items.each do |spine_item|

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
          epub.add(entry_name: new_entry_name, entry_content: File.read(destpath))
          unless new_entry_name == spine_item.name
            epub.remove(entry_name: spine_item.name)
          end
        end
      end

      output_epub_file = File.join(File.dirname(epub_file), File.basename(epub_file, ".*") + "_migrate.epub")
      if File.exist?(output_epub_file)
        FileUtils.remove(output_epub_file)
      end

      epub.save(epub_file: output_epub_file)
      puts "Wrote #{output_epub_file}"
    end
  end
end
