module UMPTG::Fulcrum::Manifest
  require 'htmlentities'

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
              if csv_file.nil? or csv_file.strip.empty? or !File.exists?(csv_file)
        csv_body = { csv_file => [File.read(csv_file)] }
      when @properties.key?(:monograph_id)
        service = UMPTG::Services::Heliotrope.new(
                        :fulcrum_host => @properties[:fulcrum_host]
                      )
        csv_body = service.monograph_export(noid: @properties[:monograph_id])
        csv_body = service.monograph_export(identifier: @properties[:monograph_id]) \
                      if csv_body[@properties[:monograph_id]].empty?
        csv_body = nil if csv_body[@properties[:monograph_id]].empty?
      else
        # No content specified
        csv_body = nil
      end

      #raise "Error: manifest is empty" if csv_body.nil? or csv_body.empty?
      return "" if csv_body.nil? or csv_body.empty?

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

    def representative_row(args = {})
      return nil unless args.has_key?(:kind)

      kind = args[:kind]
      row = @csv.find {|row| row['representative_kind'] == kind.downcase }
      #raise "Error: representative #{kind} not found" if row.nil?
      return row
    end

    def fileset(file_name)
      unless file_name.nil?
        file_name_base = File.basename(file_name, ".*").downcase
        fileset_row = @csv.find {|row| !row['file_name'].nil? and File.basename(row['file_name'], ".*").downcase == file_name_base }
        if fileset_row.nil?
          fn = HTMLEntities.new.decode(file_name)
          fileset_row = @csv.find {|row| row['external_resource_url'] == fn }
        end
        return fileset_row unless fileset_row.nil?
      end

      return EMPTY_FILESET
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

    # Method generates XML markup to link a resource.
    #
    # Parameter:
    #   descr           Text to include within the link
    def fileset_link_markup(file_name, descr = nil)
      descr = "View resource." if descr == nil

      link_markup = ""
      fileset = fileset(file_name)
      noid = fileset["noid"]
      unless noid.empty?
        link = fileset["doi"]
        link = fileset["link"] if link.empty?
        link_markup = "<a href=\"#{link}\" target=\"_blank\">#{descr}</a>"
      end
      return link_markup
    end

    # Method generates the XML markup for embedding
    # a specific resource.
    def fileset_embed_markup(file_name)
      fileset = fileset(file_name)
      #emb_markup = fileset["embed_code"] unless fileset["noid"].empty?
      noid = fileset["noid"]
      embed_markup = ""
      unless noid.empty?
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
