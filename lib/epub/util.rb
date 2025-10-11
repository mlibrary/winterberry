module UMPTG::EPUB

  require 'zip'

  class Util

    TOC_HTML = <<-THTML
    <?xml version="1.0" encoding="UTF-8"?>
    <html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
    <head>
    <meta content="initial-scale=1.0,maximum-scale=5.0" name="viewport"/>
    <title></title>
    </head>
    <body>
    <nav id="nav_toc" role="doc-toc" epub:type="toc" aria-labelledby="ncx-head">
    <h2 id="ncx-head"></h2>
    <ol>
    </ol>
    </nav>
    </body>
    </html>
    THTML

    def self.create(args = {})
      raise "Missing directory path" unless args.key?(:directory)
      dirpath = File.expand_path(args[:directory])

      case
      when args.key?(:epub_file)
        epub_file = args[:epub_file]
      else
        epub_file = File.join(File.dirname(dirpath), File.basename(dirpath) + ".epub")
      end

      Zip::OutputStream.open(epub_file) do |zos|
        # Make the mimetype the first item
        mimetype_list = Dir.glob(File.join(dirpath, "mimetype"))
        raise "Error: mimetype file missing" if mimetype_list.empty?

        mimetype_file = mimetype_list.first
        entry_name = mimetype_file.delete_prefix(dirpath + File::SEPARATOR)
        puts "Adding entry #{entry_name}"
        zos.put_next_entry(mimetype_file.delete_prefix(dirpath + File::SEPARATOR), nil, nil, Zip::Entry::STORED)
        zos.write(File.read(mimetype_file, mode: "rb"))

        Dir.glob(File.join(dirpath, "**", "*")).each do |fpath|
          unless File.directory?(fpath) or File.basename(fpath) == 'mimetype'
            entry_name = fpath.delete_prefix(dirpath + File::SEPARATOR)
            puts "Adding entry #{entry_name}"
            zos.put_next_entry(entry_name)
            zos.write(File.read(fpath, mode: "rb"))
          end
        end
      end
    end

    # Convert a NCX TOC to a HTML TOC.
    def self.ncx_to_xhtml(ncx_doc)
      toc_doc = Nokogiri::XML.parse(TOC_HTML)

      ncx_title_node = ncx_doc.xpath("//*[local-name()='docTitle']/*[local-name()='text']").first

      toc_headtitle_node = toc_doc.xpath("//*[local-name()='head']/*[local-name()='title']").first
      raise "TOC head/title not found" if toc_headtitle_node.nil?
      toc_headtitle_node.content = ncx_title_node.content

      toc_nav_node = toc_doc.xpath("//*[local-name()='nav']").first
      raise "TOC nav not found" if toc_nav_node.nil?

      toc_ol_node = toc_nav_node.xpath("./*[local-name()='ol']").first
      raise "TOC nav/ol not found" if toc_ol_node.nil?

      ncx_title_node = ncx_doc.xpath("//*[local-name()='docTitle']/*[local-name()='text']").first
      toc_title_node = toc_nav_node.xpath("./*[local-name()='h2']").first
      raise "TOC nav/title not found" if toc_title_node.nil?

      toc_title_node.content = ncx_title_node.content

      ncx_doc.xpath("//*[local-name()='navPoint']").each do |ncx_node|
        id = ncx_node["id"]
        title = ncx_node.xpath("./*[local-name()='navLabel']/*[local-name()='text']").first.content
        href = ncx_node.xpath("./*[local-name()='content']").first["src"]

        markup = "<li id=\"#{id}\"><a href=\"#{href}\">#{title}</a></li>"
        toc_ol_node.add_child(markup)
      end
      return toc_doc
    end

    def self.update_ncx_identifier(ncx_doc, epub_identifier)
      ncx_head_node = ncx_doc.xpath("/*[local-name()='ncx']/*[local-name()='head']").first
      unless ncx_head_node.nil?
        dtb_uid_node = ncx_head_node.xpath("./*[local-name()='meta' and @name='dtb:uid']").first
        if dtb_uid_node.nil?
          ncx_head_node.add_child("<meta name=\"dtb:uid\" content=\"#{epub_identifier}\"/>")
        else
          dtb_uid_node['content'] = epub_identifier
        end
      end
    end
  end
end
