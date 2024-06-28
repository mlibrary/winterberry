module UMPTG
  require 'csv'
  require 'xsv'

  require_relative File.join("..", "..", "lib", "object")
  require_relative File.join("..", "..", "lib", "xml", "util")

  TYPE2ROLE = {
      "acknowledgments" => "doc-acknowledgments",
      "abstract" => "doc-abstract",
      "afterword" => "doc-afterword",
      "appendix" => "doc-appendix",
      "backlink" => "doc-backlink",
      "biblioentry" => "doc-biblioentry",
      "bibliography" => "doc-bibliography",
      "biblioref" => "doc-biblioref",
      "chapter" => "doc-chapter",
      "colophon" => "doc-colophon",
      "conclusion" => "doc-conclusion",
      "cover" => "frontmatter",
      "credits" => "doc-credits",
      "endnotes" => "doc-endnotes",
      "errata" => "doc-errata",
      "foreword" => "doc-foreword",
      "glossary" => "doc-glossary",
      "glossref" => "doc-glossref",
      "epigraph" => "doc-epigraph",
      "footnote" => "doc-footnote",
      "index" => "doc-index",
      "introduction" => "doc-introduction",
      "noteref" => "doc-noteref",
      "notice" => "doc-notice",
      "page-list" => "doc-pagelist",
      "pagebreak" => "doc-pagebreak",
      "part" => "doc-part",
      "preface" => "doc-preface",
      "prologue" => "doc-prologue",
      "pullquote" => "doc-pullquote",
      "subtitle" => "doc-subtitle",
      "tip" => "doc-tip",
      "toc" => "doc-toc"
    }

  TEMPLATE_XML = <<-TXPATH
<?xml version="1.0" encoding="UTF-8"?>
<html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta content="initial-scale=1.0,maximum-scale=5.0" name="viewport"/>
<title></title>
<link href="default.css" rel="stylesheet" type="text/css"/>
<meta charset="UTF-8"/></head>
<body></body>
</html>
  TXPATH

  FRONTMATTER_SECTION_XML =  <<-FXML
<section class="chapter">
<header><h1 class="ctfm" role="frontmatter_header"></header>
</section>
  FXML

  TITLEPAGE_SECTION_XML = <<-FXML
<section id="sect_titlepage" class="chapter" role="titlepage"><h1 role="sect_titlepage_header"></h1></section>
  FXML

  COVER_SECTION_XML =  <<-FXML
<section id="sect_cover" class="chapter" role="cover">
<div class="cover">
<p class="fig"><img alt="Cover" role="doc-cover"/></p>
</div>
</section>
  FXML

  class Manuscript < UMPTG::Object
    attr_reader :path, :xml_doc, :metadata, :title, :languages, :creators, :isbns

    def initialize(dirpath = nil, args = {})
      a = args.clone
      a[:path] = dirpath
      super(a)
      @path = dirpath
      @xml_doc = nil

      @metadata = monograph_metadata

      @title = @metadata["Title"]

      isbns_list = @metadata["ISBN(s)"]
      @isbns = isbns_list.nil? ? [] : isbns_list.split(';')

      languages_list = @metadata["Language"]
      @languages = languages_list.nil? ? [] : languages_list.split(';')

      creators_list = @metadata["Creator(s)"]
      @creators = creators_list.nil? ? [] : creators_list.split(';')
    end

    def template_doc(args = {})
      doc = UMPTG::XML.parse(xml_content: TEMPLATE_XML)
      doc.root.add_namespace("epub", "http://www.idpf.org/2007/ops")
      return doc
    end

    def generate_xml_doc(args = {})
      document_list = document_files
      if document_list.count == 1
        doc = UMPTG::XML.parse(xml_file: document_list.first)
        body_node = doc.xpath("//*[local-name()='body']").first
      else
        doc = template_doc(args)

        body_node = doc.xpath("//*[local-name()='body']").first

        document_files.each do |document_file|
          document_doc = UMPTG::XML.parse(xml_file: document_file)
          document_body_node = document_doc.xpath("//*[local-name()='body']").first
          body_node.add_child(document_body_node.inner_html)
        end

        body_node.xpath(".//*[@href]").each do |n|
          href = n['href']
          href = href.nil? ? "" : href.strip
          next if href.empty?

          s = href.split('#')
          if s.count > 1
            next if s[0].start_with?("http")

            #puts "href:#{n['href']},#{s[0]},#{s[1]}"
            n['href'] = "#" + s[1]
          end
        end
      end
      doc.root.add_namespace("epub", "http://www.idpf.org/2007/ops")

      #doc_title = doc.xpath("//*[local-name()='head']/*[local-name()='title']").first.content
      doc_title = @title
      s_node = doc.xpath("//*[local-name()='body']/*[local-name()='section'][1]").first

      # Cover page generated
      section_doc = Nokogiri::XML::Document.parse(COVER_SECTION_XML)
      cover_file = Dir.glob(File.join(media_dir, "[Cc]over.*")).first
      unless cover_file.nil?
        img_node = section_doc.xpath("//*[local-name()='img' and @role='doc-cover']").first
        img_node["alt"] = "Cover: " + doc_title
        #img_node["src"] = cover_file.delete_prefix(manuscript.path))[1..-1]
        img_node["src"] = File.join("..", File.basename(media_dir), File.basename(cover_file))
      end
      s_node.add_previous_sibling(section_doc.root)

      # Title page
      section_doc = Nokogiri::XML::Document.parse(TITLEPAGE_SECTION_XML)
      node = section_doc.xpath("//*[@role='sect_titlepage_header']").first
      node.remove_attribute("role")
      node.inner_html = doc_title
      s_node.add_previous_sibling(section_doc.root)

      # TOC
      section_doc = Nokogiri::XML::Document.parse(FRONTMATTER_SECTION_XML)
      role = "toc"
      section_doc.root["role"] = role
      section_doc.root["id"] = "sect_" + role
      node = section_doc.xpath("//*[@role='frontmatter_header']").first
      node.remove_attribute("role")
      node.inner_html = "Contents"
      s_node.add_previous_sibling(section_doc.root)

      # List of Figures
      section_doc = Nokogiri::XML::Document.parse(FRONTMATTER_SECTION_XML)
      role = "figurelist"
      section_doc.root["role"] = role
      section_doc.root["id"] = "sect_" + role
      node = section_doc.xpath("//*[@role='frontmatter_header']").first
      node.remove_attribute("role")
      node.inner_html = "List of Figures"
      s_node.add_previous_sibling(section_doc.root)

      # Confirm all sections have IDs
      section_cntr = 0
      section_nodes = body_node.xpath("./*[local-name()='section']")
      section_nodes.each do |section_node|
        section_cntr += 1
        section_id = section_node["id"]
        if section_id.nil? or section_id.strip.empty?
          section_id = "sect_#{section_cntr.to_s.rjust(3, "0")}"
          section_node["id"] = section_id
        end
      end

      # Add TOC entries
      body_node.xpath("//*[@role='toc']").each do |node|
        section_nodes.each do |section_node|
          section_id = section_node["id"]
          role = section_node["role"]
          title_node = section_node.xpath(".//*[local-name()='header' or local-name()='h1']").first
          if title_node.nil?
            title = ""
          else
            hn = title_node.dup(1)
            hn.xpath(".//*[local-name()='span']").each {|n| n.remove}
            title = hn.content.strip.gsub(/\s+/, " ")
          end

          case role
          when "cover"
            cls = "tocfm"
            title = "Cover"
          when "titlepage"
            cls = "tocfm"
            title = "Title Page"
          when "frontmatter", "titlepage", "toc"
            cls = "tocfm"
          when "backmatter", "index"
            cls = "tocbm"
          else
            cls = "toc"
          end
          unless title.empty?
            href = "#" + section_id
            markup = "<p class=\"#{cls}\"><a class=\"xref\" href=\"#{href}\">#{title}</a></p>"
            node.add_child(markup)
          end
        end
      end

      # Add Figure entries
      body_node.xpath("//*[@role='figurelist']").each do |node|
        fig_cntr = 0
        body_node.xpath(".//*[local-name()='figure']").each do |fig_node|
          fig_id = fig_node["id"]
          if fig_id.nil? or fig_id.strip.empty?
            fig_cntr += 1
            fig_id = "fig#{fig_cntr}"
            fig_node["id"] = fig_id
          end
          fig_href = "#" + fig_id

          fig_caption_node = fig_node.xpath("./*[local-name()='figcaption']").first
          fig_caption = fig_caption_node.nil? ? fig_caption = fig_id : fig_caption = fig_caption_node.text
          markup = "<p class=\"tocill\"><a class=\"xref\" href=\"#{fig_href}\">#{fig_caption}</a></p>"
          node.add_child(markup)
        end
      end

      section_nodes.each do |section_node|
        section_id = section_node["id"]
        section_aria_label = section_node["aria-labelledby"]

        if section_aria_label.nil?
          header_node = section_node.xpath("./*[local-name()='header' or local-name()='h1']").first
          unless header_node.nil?
            header_id = header_node["id"]
            if header_id.nil? or header_id.strip.empty?
              header_id = section_id + "_header"
              header_node["id"] = header_id
            end
            section_node["aria-labelledby"] = header_id
          end
        end

        nlist = section_node.xpath("descendant-or-self::*[@role]")
        nlist.each do |n|
          if n.key?("role")
            role = n["role"]
            case role
            when "cover", "figurelist"
              n["epub:type"] = "frontmatter"
            when "doc-cover"
            else
              n["epub:type"] = role
            end

            new_role = TYPE2ROLE[role]
            if new_role.nil? or new_role.strip.empty?
              n.remove_attribute("role") unless role == "doc-cover"
            else
              n['role'] = new_role
              n.remove_attribute("role") if role == "cover"
            end
          end
        end
      end

      @xml_doc = doc
    end

    def monograph_metadata
      mfile = monograph_metadata_file
      body_list = []
      if File.extname(mfile) == ".xlsx" or File.extname(mfile) == ".xls"
        x = Xsv::Workbook.open(mfile)
        sheet = x.sheets[0]
        raise "Error: no sheets for #{mfile}" if sheet.nil?

        body_list = sheet.collect {|r| CSV.generate_line(r) unless r.compact.empty? }
      else
        body_list = File.open(mfile).readlines
      end

      CSV::Converters[:strip_field] = ->(value) { value.strip rescue value }
      begin
        csv_data = CSV.parse(
                  body_list.join,
                  headers: true,
                  converters: :strip_field,
                  return_headers: false)
       #          :header_converters => lambda { |h| h.downcase.gsub(' ', '_') })
       #          :headers => true, :converters => :all,
      rescue Exception => e
        raise e.message
      end
      return csv_data[-1]
    end

    def monograph_metadata_file
      f = Dir.glob(File.join(@path, "monograph_metadata.*")).first
      return f.nil? ? "" : f
    end

    def manuscript_dir
      return File.join(@path, "manuscript")
    end

    def media_dir
      return File.join(manuscript_dir, "media")
    end

    def media_files
      return Dir.glob(File.join(media_dir, "*"))
    end

    def document_dir
      return File.join(manuscript_dir, "document")
    end

    def document_files
      return Dir.glob(File.join(document_dir, "*"))
    end
  end
end
