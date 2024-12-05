module UMPTG::Fulcrum::Manifest
  require 'htmlentities'
  require 'redcarpet'
  require 'uri'

  require_relative('xhtmlrenderer')

  @@BLANK_ROW_FILE_NAME = "***row left intentionally blank***"
  #@@BLANK_ROW_FILE_NAME = "*** row intentionally left blank ***"

  @@MONOGRAPH_FILE_NAME = '://:MONOGRAPH://:'

  EMPTY_FILESET = {
          "noid" => "",
          "file_name" => "",
          "resource_name" => "",
          "link" => "",
          "embed_code" => ""
       }

  RESOURCE_EMBED_MARKUP = <<-REMARKUP
  <link href="%s/downloads/%s?file=embed_css" rel="stylesheet" type="text/css"/>
  <div id="fulcrum-embed-outer-%s">
  <div id="fulcrum-embed-inner-%s">
  <iframe id="fulcrum-embed-iframe-%s" src="%s" title="%s" allowfullscreen="true"/>
  </div>
  </div>
  REMARKUP

  LINK_HREF_MARKUP = "%s/downloads/%s?file=embed_css"

  RESOURCE_IDENT_REGEX = "[;]?[ ]*youtube_id:[ ]*(%s)[ ]*[;]?"

  class Document < UMPTG::Object
    attr_reader :name, :noid, :csv, :monograph_row, :isbn, :headers

    def initialize(args = {})
      super(args)

      @name = @properties[:name]

      case
      when @properties.key?(:csv_body)
        body = @properties[:csv_body]
        csv_body = { body => [ body ]}
      when @properties.key?(:csv_file)
        csv_file = @properties[:csv_file]
        raise "Error: invalid CSV file path #{csv_file}" \
              if csv_file.nil? or csv_file.strip.empty? or !File.exist?(csv_file)
        csv_body = { csv_file => [File.read(csv_file)] }
      when @properties.key?(:monograph_id)
        service = UMPTG::Services::Heliotrope.new(
                        :fulcrum_host => @properties[:fulcrum_host]
                      )
        csv_body = service.monograph_export(noid: @properties[:monograph_id])
        csv_body = service.monograph_export(identifier: @properties[:monograph_id]) \
                      if csv_body[@properties[:monograph_id]].empty?
        csv_body = nil if csv_body[@properties[:monograph_id]].empty?

        raise "found #{csv_body[@properties[:monograph_id]].count} manifests for identifier #{@properties[:monograph_id]}" \
            unless csv_body.nil? or csv_body[@properties[:monograph_id]].count < 2
      else
        # No content specified
        csv_body = nil
      end

      #raise "Error: manifest is empty" if csv_body.nil? or csv_body.empty?
      return if csv_body.nil? or csv_body.empty?

      csv_body.each do |key,manifest_list|
        manifest_list.each do |manifest_body|
          begin
            tcsv = CSV.parse(
                      manifest_body,
                      :headers => true,
                      :return_headers => false
                      )
          rescue Exception => e
            raise e.message
          end
          @headers = tcsv.headers

          begin
            @csv = CSV.parse(
                      manifest_body,
                      :headers => true,
                      :return_headers => false,
                      :header_converters => lambda { |h| h.strip.downcase.gsub(' ', '_') })
           #          :headers => true, :converters => :all,
          rescue Exception => e
            raise e.message
          end

          @monograph_row = @csv.find {|row| row['file_name'] == UMPTG::Fulcrum::Manifest.MONOGRAPH_FILE_NAME }
          @noid = @monograph_row['noid'] unless @monograph_row.nil?
          @isbn = {}
          unless @monograph_row.nil?
            @isbn = parse_isbns(@monograph_row['isbn(s)'])
          end
        end
      end
    end

    def representatives()
      r = {}
      @csv.each do |row|
        next unless ['false','true'].include?(row['published?'].downcase)

        noid = row['noid']
        kind = row['representative_kind']
        unless noid.nil? or noid.empty? or kind.nil? or kind.empty?
          r[kind] = row
        end
      end
      return r
    end

    def representative_row(args = {})
      return nil unless args.has_key?(:kind)

      kind = args[:kind]
      row = @csv.find {|row| row['representative_kind'] == kind.downcase }
      #raise "Error: representative #{kind} not found" if row.nil?
      return row
    end

    def fileset_ident(file_name)
      regex = sprintf(RESOURCE_IDENT_REGEX, file_name)
      fileset_row = @csv.find {|row| !row['identifier(s)'].nil? and row['identifier(s)'].match?(regex) }
      fileset_row['file_name'] = file_name unless fileset_row.nil?
      return fileset_row
    end

    def fileset(file_name)
      unless file_name.nil?
        file_name_base = File.basename(file_name, ".*")
        file_name_base_lc = file_name_base.downcase
        fileset_row = @csv.find {|row| !row['file_name'].nil? and File.basename(row['file_name'], ".*").downcase == file_name_base_lc }
        if fileset_row.nil?
          file_name_base_lc = file_name_base_lc.gsub(/[ ]+/, '_')
          fileset_row = @csv.find {|row| !row['file_name'].nil? and File.basename(row['file_name'], ".*").downcase == file_name_base_lc }
        end

        fileset_row = fileset_ident(file_name_base) if fileset_row.nil?

        if fileset_row.nil?
          fn = HTMLEntities.new.decode(file_name)
          fileset_row = @csv.find {|row| row['external_resource_url'] == fn }
        end
        return fileset_row unless fileset_row.nil?
      end

      return EMPTY_FILESET
    end

    def fileset_exists(file_name)
      f = fileset(file_name)
      return !f["file_name"].strip.empty?
    end

    def fileset_from_noid(noid)
      if noid != nil
        fileset_row = @csv.find {|row| row['noid'] == noid }
        return fileset_row unless fileset_row.nil?
      end

      return EMPTY_FILESET
    end

    def filesets()
      return @csv.select {|row|
          (
            row['representative_kind'].nil? \
            or row['representative_kind'].empty?
          ) \
          and \
          !(\
              row['resource_type'].nil? \
              or row['resource_type'].empty? \
              or row['resource_type'].downcase.start_with?("translation missing:")
           )
        }
    end

    # Method returns the file name for a resource.
    def fileset_file_name(file_name)
      fileset = fileset(file_name)
      fname = fileset['file_name']
      if fname.nil? or fname.empty?
        ident = fileset['identifier(s)']
        unless ident.nil?
          regex = sprintf(RESOURCE_IDENT_REGEX, file_name)
          m = ident.match(regex)
          fname = m[1] unless m.nil?
        end
      end

      return fname.nil? ? "" : fname
    end

    # Method returns the file name for a resource.
    def fileset_external_resource_url(file_name)
      fileset = fileset(file_name)
      url = fileset['external_resource_url']
      return url.nil? ? "" : url.strip
    end

    # Method returns the file name for a resource.
    def fileset_alt(file_name)
      fileset = fileset(file_name)
      alt = fileset['alternative_text']
      return alt.nil? ? "" : alt
    end

    # Method returns the caption for a resource.
    def fileset_caption(file_name)
      fileset = fileset(file_name)
      caption = fileset['caption']
      caption = fileset['title'] if caption.nil? or caption.strip.empty?
      caption = "" if caption.nil? or caption.strip.empty?

      extensions = {
        autolink: true,
        fenced_code_blocks: true
      }
      @markdown = Redcarpet::Markdown.new(
                XHTMLRenderer,
                #Redcarpet::Render::HTML,
                extensions
              )
      @entity_encoder = HTMLEntities.new
      caption = @markdown.render(@entity_encoder.encode(caption.force_encoding("UTF-8")))

      return caption
    end

    # Method returns the caption for a resource.
    def fileset_title(file_name)
      fileset = fileset(file_name)
      caption = fileset['title']
      caption = "" if caption.nil? or caption.strip.empty?
      return caption
    end

    # Method returns the Allow Download for a resource.
    def fileset_allow_download(file_name)
      fileset = fileset(file_name)
      allow_download = fileset['allow_download?']
      return false if allow_download.nil? or allow_download.strip.empty?
      allow_download = allow_download.strip.downcase
      return (allow_download == "true" or allow_download == "yes")
    end

    # Method returns the link for a resource.
    def fileset_link(file_name, args = {})
      download = args.key?(:download) ? args[:download] : false

      fileset = fileset(file_name)
      noid = fileset["noid"]
      file_name = fileset['file_name']
      doi = fileset["doi"]

      link = ""
      unless file_name.empty?
        if download
          link = doi + "?urlappend=%3fdownload=true" unless doi.nil? or doi.strip.empty?
          link = fileset["handle"] if link.empty?
          link = "https://www.fulcrum.org/downloads/#{noid}" if link.nil? or link.strip.empty?
        else
          link = doi || ""
          link = fileset["handle"] || "" if link.strip.empty?
          link = fileset["link"] || "" if link.strip.empty?
          link = link[12..-3] if link.start_with?("=HYPERLINK")
          #link = fileset["link"][12..-3] if link.nil? or link.strip.empty?
        end
      end
      return link
    end

    # Method generates XML markup to link a resource.
    #
    # Parameter:
    #   descr           Text to include within the link
    def fileset_link_markup(file_name, args = {})
      descr = args[:description]
      descr = fileset_caption(file_name) if descr.nil?

      link = fileset_link(file_name, args)
      return link.empty? ? "" : "<a href=\"#{link}\" target=\"_blank\">#{descr}</a>"
    end

    # Method generates the XML markup for embedding
    # a specific resource.
    def fileset_embed_markup(file_name)
      fileset = fileset(file_name)
      #emb_markup = fileset["embed_code"] unless fileset["noid"].empty?
      noid = fileset["noid"]
      file_name = fileset["file_name"]
      embed_markup = ""
      unless file_name.empty?
        # Found fileset. Determine the embed link from the
        # "Embed Code" property. This will give the correct host.
        # If fileset has no property, then it can't be embedded.
        external_res = fileset['external_resource_url']
        fmarkup = fileset['embed_code']
        unless fmarkup.nil? or fmarkup.empty?
          if external_res.nil? or external_res.strip.empty?
            embed_doc = Nokogiri::XML::DocumentFragment.parse(fmarkup)
            iframe_node = embed_doc.xpath("descendant-or-self::*[local-name()='iframe']").first
            embed_link = iframe_node['src']
            ititle = iframe_node['title']
            title = HTMLEntities.new.encode(ititle)

            href = fileset['link'][12..-3]
            #title = fileset['title'].nil? ? "" : fileset['title']

            link_uri = URI(embed_link)
            link_scheme_host = link_uri.scheme + "://" + link_uri.host

            embed_markup = sprintf(RESOURCE_EMBED_MARKUP, link_scheme_host, noid, noid, noid, noid, embed_link, title)
          else
            embed_markup = fmarkup
          end
        end
      end
      return embed_markup
    end

    # Method generates the XML JATS markup for embedding
    # a specific resource.
    def fileset_embed_jats_markup(args = {})
      file_name = args[:file_name]
      caption_markup = args[:caption_markup]
      renderer = args[:renderer]

      fileset = fileset(file_name)
      #emb_markup = fileset["embed_code"] unless fileset["noid"].empty?
      noid = fileset["noid"]
      file_name = fileset["file_name"]
      embed_markup = ""

      unless file_name.empty?
        embed_markup = fileset['embed_code']
        unless embed_markup.nil? or embed_markup.empty?
          embed_doc = Nokogiri::XML::DocumentFragment.parse(embed_markup)
          iframe_node = embed_doc.xpath("descendant-or-self::*[local-name()='iframe']").first
          embed_link = iframe_node['src']
        end

        link_uri = URI(embed_link)
        link_scheme_host = link_uri.scheme + "://" + link_uri.host

        href = fileset['link'][12..-3]
        title = fileset['title'].nil? ? "" : fileset['title']
        caption = fileset['caption'].nil? ? "" : fileset['caption']
        doi = fileset['doi'].nil? ? "" : fileset['doi']

        @entity_encoder = HTMLEntities.new
        extensions = {
          autolink: true,
          fenced_code_blocks: true
        }
        @markdown = Redcarpet::Markdown.new(
                  renderer,
                  extensions
                )

        title = @markdown.render(@entity_encoder.encode(title.force_encoding("UTF-8")))
        caption = @markdown.render(@entity_encoder.encode(caption.force_encoding("UTF-8")))

        doi_noprefix = doi.delete_prefix("https://doi.org/")
        embed_code = fileset['embed_code']
        noid = fileset['noid']

        css_link = sprintf(LINK_HREF_MARKUP, link_scheme_host, noid)

        media_doc = Nokogiri::XML::Document.new
        media_element = media_doc.create_element("media")

        media_element['xlink:href'] = embed_link
        media_element['mimetype'] = fileset['resource_type']
        media_element['mime-subtype'] = File.extname(fileset['file_name'])[1..-1].downcase
        media_element['position'] = 'anchor'
        media_element['specific-use'] = 'online'

        unless title.strip.empty? and (caption.strip.empty? or caption_markup.nil?)
          caption_element = add_element("caption", media_element)
          if caption_markup.nil?
            add_element_unless_no_content("title", caption_element, title)
            add_element_unless_no_content("p", caption_element, caption)
          else
            caption_element.add_child(caption_markup)
          end
        end
        add_element_unless_no_content(
                "object-id",
                media_element,
                doi_noprefix,
                {
                    "pub-id-type" => "doi"
                }
                )

        attrib_element = add_element(
              "attrib",
              media_element,
              '',
              {
                  "id" => "umptg_fulcrum_resource_" + noid,
                  "specific-use" => "umptg_fulcrum_resource"
              }
              )

        unless doi.strip.empty?
          add_ext_link(
              attrib_element,
              {
                "ext-link-type" => "doi",
                "xlink:href" => doi_noprefix
              }
              )
        end

        add_ext_link(
            attrib_element,
            {
              "ext-link-type" => "uri",
              "specific-use" => "umptg_fulcrum_resource_link",
              "xlink:href" => href
            }
            )
        add_ext_link(
            attrib_element,
            {
              "ext-link-type" => "uri",
              "specific-use" => "umptg_fulcrum_resource_css_stylesheet_link",
              "xlink:href" => css_link
            }
            )
        add_ext_link(
            attrib_element,
            {
              "ext-link-type" => "uri",
              "specific-use" => "umptg_fulcrum_resource_embed_link",
              "xlink:href" => embed_link
            }
            )

        alt_element = add_element("alternatives", attrib_element)
        add_element(
              "preformat",
              alt_element,
              noid,
              {
                  "specific-use" => "umptg_fulcrum_resource_identifier",
                  "position" => "anchor"
              }
              )
        add_element_unless_no_content(
                "preformat",
                alt_element,
                title,
                {
                    "specific-use" => "umptg_fulcrum_resource_title",
                    "position" => "anchor"
                }
                )
        return media_element.to_xml
      end
    end

    private

    def parse_isbns(isbns_property)
      isbns_property = @monograph_row['isbn(s)']
      isbn_format = {}
      unless isbns_property.nil? or isbns_property.empty?
        isbns_list = isbns_property.split(';').each do |isbn|
          list = isbn.strip.downcase.match('([0-9\-]+)[ ]+\(([^\)]+)\)')
          unless list.nil?
            isbn_format[list[2]] = list[1]
          end
        end
      end
      return isbn_format
    end

    def add_element(elemName, parentElem, content = '', attrs = {})
      child_elem = parentElem.document.create_element(elemName)
      parentElem.add_child(child_elem)
      unless content.strip.empty?
        #child_elem.content = content
        nl = child_elem.parse(content)
        child_elem.add_child(nl)
      end

      attrs.each do |attrName,attrValue|
        child_elem[attrName] = attrValue unless attrValue.strip.empty?
      end
      return child_elem
    end

    def add_element_unless_no_content(elemName, parentElem, content = '', attrs = {})
      return add_element(elemName, parentElem, content, attrs) \
            unless content.strip.empty?
    end

    def add_ext_link(parentElem, attrs = {})
      return add_element("ext-link", parentElem, '', attrs)
    end
  end

  def self.blank_row_name?(row_name)
    return false if row_name.nil?

    rname = row_name.downcase.strip
    return rname.strip.match?(/^\*\*\*[ ]*row[ ]+/)
  end

  def self.BLANK_ROW_FILE_NAME
    return @@BLANK_ROW_FILE_NAME
  end

  def self.MONOGRAPH_FILE_NAME
    return @@MONOGRAPH_FILE_NAME
  end
end
