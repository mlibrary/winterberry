module UMPTG::EPUB

  class OPFArchiveEntry < ArchiveEntry

    def write(output_stream, args = {})
      modified_date = Time.now.strftime("%Y-%m-%dT%H:%M:%S") + "Z"
      doc = document.clone
      Rendition.add_modified(
            doc,
            value: modified_date
            )
      ArchiveEntry.write(
          output_stream,
          entry_name: name,
          entry_content: doc.to_xml
        )
    end
  end
end
