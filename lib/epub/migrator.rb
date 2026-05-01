module UMPTG::EPUB

  require_relative 'pipeline'
  require_relative 'util'

  class Migrator < Pipeline::Processor
    def initialize(name, processors: {}, filters: nil, options: {}, logger: nil)
      options = {
            epub_ncx_content: true,
            epub_ncx_navigation: true,
            epub_oebps_opf: true,
            xhtml_migration: true,
            xhtml_entity: false
          }
      super(
            name,
            processors: processors,
            options: options,
            logger: logger
          )
    end

    def run(epub, options: {}, logger: nil)
      epub_version = epub.rendition.version || ""
      logger.info("version: #{epub_version}")
      if epub_version.start_with?("3.")
        logger.info("EPUB 3.x compliant. Skipping")
        return []
      end
      entry_actions = super(epub, options: options, logger: logger)
      process_entry_action_results(epub, options: options, logger: logger)
      return entry_actions
    end

    def process_entry_action_results(epub, options: {}, logger: nil)
      normalize = options[:normalize] || false
      if normalize
        llogger = logger || @logger

        ncx_entry = epub.files.find(media_type: "application/x-dtbncx+xml").first
        unless ncx_entry.nil?

          # Update the NCX identifier to match the OPF identifier
          opf_doc = epub.rendition.entry.document
          uniq_id = opf_doc.xpath("//*[local-name()='package']/@unique-identifier") || ""
          unless uniq_id.empty?
              n = opf_doc.xpath("//*[local-name()='package']/*[local-name()='metadata']/*[@id='#{uniq_id}']").first
              epub_identifier = n.nil? ? "" : n.content
          end

          if epub_identifier.empty?
            identifiers = epub.rendition.metadata.dc.elements.identifier.collect {|d| d.text}
            epub_identifier = identifiers.first || ""
          end

          unless epub_identifier.empty?
            UMPTG::EPUB::Util.update_ncx_identifier(ncx_entry.document, epub_identifier)
            epub.files.add(
                  entry_name: ncx_entry.name,
                  entry_content: UMPTG::XML.doc_to_xml(ncx_entry.document)
                )
            llogger.info("Updated identifier to \"#{epub_identifier}\"")
          end

          # Generate XHTML navigation file
          toc_doc = UMPTG::EPUB::Util.ncx_to_xhtml(ncx_entry.document)

          ncx_name = ncx_entry.name
          toc_name = File.join(File.dirname(ncx_name), File.basename(ncx_name, ".*") + "_navigation.xhtml")
          epub.rendition.manifest.add(
                entry_name: toc_name,
                entry_content: UMPTG::XML.doc_to_xml(toc_doc),
                media_type: "application/xhtml+xml",
                entry_properties: "nav"
              )
        end

        # Update file name extensions
        xhtml_entries = epub.files.find(media_type: "application/xhtml+xml") \
                + epub.files.find(media_type: "text/html")
        xhtml_entries.each do |entry|
          next if entry.nil?

          nme = entry.name
          new_name = UMPTG::XHTML.fix_ext(entry.name)
          unless nme == new_name
            epub.rendition.manifest.rename(
                entry_name: nme,
                entry_new_name: new_name
              )
            epub.rendition.guide.rename(
                entry_name: nme,
                entry_new_name: new_name
              )
=begin
            epub.files.add(
                entry_name: new_name,
                entry_content: entry.content
              )
            epub.files.remove(entry_name: nme)
=end
            llogger.info("renamed entry #{nme} to #{new_name}")
          end
        end
      end
    end
  end
end
