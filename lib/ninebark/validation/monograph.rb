
MONOGRAPH_FILE_NAME = '://:MONOGRAPH://:'
BLANK_LINE1 = '***row left intentionally blank***'
BLANK_LINE2 = '***row intentionally left blank***'
BLANK_LINE3 = '***this row left intentionally blank***'

class Monograph

  require 'htmlentities'
  require 'yaml'

  attr_reader :xml_markup

  @@ent_coder = nil

  def initialize(args = {})
    @name = args[:name]

    @xml_markup = ""
  end

  def load(args = {})
    @@ent_coder = HTMLEntities.new if @@ent_coder.nil?

    case
    when args.key?(:manifest_csv_body)
      manifest_csv_body = args[:manifest_csv_body]
      manifest_csv = CSV.parse(
            manifest_csv_body,
            :headers => true,
            :return_headers => false,
            :header_converters => lambda { |h| CollectionSchema.normalize(h) }
            )
    when args.key?(:manifest_csv)
      manifest_csv = args[:manifest_csv]
    else
      raise "ERROR: :manifest_csv_body or :manifest_csv must be specified."
    end

    monograph_row = nil
    content = {
          :metadata => "",
          :representative => "",
          :resource => ""
          }

    csv_headers = manifest_csv.headers
    if !csv_headers.nil?
      csv_headers.each do |field_name|
        puts "Error: unknown field name \"#{field_name}\"." unless CollectionSchema.header?(field_name)
      end
    end

    manifest_csv.each do |row|
      file_name = row["file_name"]
      next if file_name.nil? or file_name.start_with?("translation missing:") \
          or file_name.match?('^[\*]{3}.*[\*]{3}$')

      skip_object_type = :metadata
      content_type = :resource
      if file_name == MONOGRAPH_FILE_NAME
        manifest_row = row
        skip_object_type = :file_set
        content_type = :metadata
        monograph_row = row
      elsif CollectionSchema.representative?(row["representative_kind"])
        content_type = :representative
      end

      collection_list = []
      row.each do |field_name, field_value|
        next if field_name == "file_name" or field_name == 'noid'
        next if field_name == "representative_kind" or field_name == "resource_type"

        entry = CollectionSchema.field(field_name)
        next if entry.nil?
        next if field_value == nil or field_value.strip == "" or entry[:object] == skip_object_type

        metadata_name = entry[:metadata_name]
        if metadata_name == nil or metadata_name.empty?
          puts "Warning: no metadata name for field #{field_name}"
          next
        end

        metadata_name = metadata_name.downcase
        multivalued = entry[:multivalued]
        acceptable_values = entry[:acceptable_values]

        case
        when metadata_name == 'url'
          field_value = field_value.match('^[^\(]+\(\"([^\"]+)\".*') {|m| m[1] }
        when multivalued == :yes_split, multivalued == :yes_multiline
          field_value.strip!
          #separator = multivalued == :yes_split ? ";" : "\n"
          separator = ";"
          value_list = field_value.split(separator)
          if value_list.count > 0
            new_field_value = ''
            value_list.each do |value|
              new_value = value.strip
              attrs = ''

              case
              when metadata_name == 'isbn'
                v = value.match('([^\(]*)\(([^\)]*)\)')
                if v != nil and v.length > 1
                  new_value = v[1].strip
                  attrs = " format=\"#{v[2].downcase}\""
                end
              when metadata_name == 'creator', metadata_name == 'contributor'
                v = value.match('([^\(]*)\(([^\)]*)\)')
                if v != nil and v.length > 1
                  new_value = v[1].strip
                  #attrs = " role=\"#{v[2]}\""
                end
              end

              new_value = @@ent_coder.encode(new_value)
              new_field_value += sprintf("<%s%s>%s</%s>", \
                  metadata_name, attrs, new_value, metadata_name)
            end
            metadata_name += "_list"
            field_value = new_field_value
          end
        when !acceptable_values.nil?
          #new_value = @@ent_coder.encode(CollectionSchema.normalize(field_value))
          new_value = CollectionSchema.normalize(field_value)
          if metadata_name == 'license'
            new_value = "license_" + new_value
          end
          field_value = "<#{new_value}/>"
        else
          field_value = @@ent_coder.encode(field_value)
        end

        collection_list << sprintf(CollectionSchema.MARKUP_FIELD, metadata_name, field_value, metadata_name)
      end

      case
      when content_type == :representative
        elem = row["representative_kind"].downcase
      when content_type == :resource
        elem = CollectionSchema.normalize(row["resource_type"]) unless row['resource_type'].nil?
        elem = "no_type" if row['resource_type'].nil?
      else
        elem = "metadata"
      end


      attrs = ""
      attrs = content_type == :metadata ? "" : sprintf(" label=\"%s\"", row["file_name"])
      if content_type != :metadata and row.has_key?("noid") and !row["noid"].empty?
        attrs += sprintf(" id=\"%s\"", row["noid"])
      end
      content[content_type] += sprintf(CollectionSchema.MARKUP_OBJECT, elem, attrs, collection_list.join, elem)
    end

    monograph_id = monograph_row == nil ? @name : monograph_row["noid"]
    #monograph_id = @name

    @xml_markup = sprintf(
        CollectionSchema.MARKUP_MONOGRAPH,
        sprintf(" id=\"%s\"", monograph_id),
        content[:metadata],
        content[:representative].empty? ? "" : sprintf(CollectionSchema.MARKUP_REPRESENTATIVES, content[:representative]),
        content[:resource].empty? ? "" : sprintf(CollectionSchema.MARKUP_RESOURCES, content[:resource])
        )
  end

end