module UMPTG::EPUB
  require_relative(File.join("migrator", "filters"))
  require_relative(File.join("migrator", "processor"))

  class << self
    def Migrator(args = {})
      return Migrator::Processor.new(args)
    end
  end

=begin
  require 'fileutils'
  require 'zip'
  require 'tempfile'

  class Migrator
    attr_reader :migrate_logger

    def self.migrate(args = {})
      case
      when args.key?(:epub)
        epub = args[:epub]
        epub_file = epub.epub_file
      when args.key?(:epub_file)
        epub_file = args[:epub_file]
        epub = Archive.new(epub_file: epub_file)
      else
        raise "Error: :epub or :epub_file not specified."
      end

      case
      when args.key?(:migrate_logger)
        @migrate_logger = args[:migrate_logger]
      else
        @migrate_logger = UMPTG::Logger.create(
                    logger_file: File.join(File.dirname(epub_file), File.basename(epub_file, ".*") + "_migrate.log")
                 )
      end

      epub.renditions.each do |rendition|
        raise "Error rendition has no name" if rendition.name.nil? or rendition.name.strip.empty?
        rend_name = File.basename(rendition.name)

        @migrate_logger.info("Processing file #{rendition.name} version #{epub.version} ==> 3.x")

        epub.version(rendition: rendition, version: "3.0")

        srcfile = Tempfile.new(rend_name)
        srcfile.write(rendition.opf_to_s)
        srcfile.close
        destpath = File.join(File.dirname(srcfile.path), rend_name)
        UMPTG::XSLT.transform(
              xslpath: File.join(UMPTG::XSLT.XSL_DIR, "update_opf.xsl"),
              srcpath: srcfile.path,
              destpath: destpath
          )
        epub.add(entry_name: rendition.name, entry_content: File.read(destpath))

        nav_items = epub.navigation(rendition: rendition)
        @migrate_logger.info("nav_items: #{nav_items.count}")
        if nav_items.empty?
          ncx_item_list = epub.ncx(rendition: rendition)
          if ncx_item_list.empty?
            @migrate_logger.warn("Warning: no NCX item found.")
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

        spine_items = epub.spine(rendition: rendition)
        spine_items.each do |spine_item|

          @migrate_logger.info("Processing file #{spine_item.name}")

          # Create the XML tree.
          srcfile = Tempfile.new(File.basename(spine_item.name))
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
      @migrate_logger.info("Saved #{output_epub_file}")
    end
  end
=end
end
