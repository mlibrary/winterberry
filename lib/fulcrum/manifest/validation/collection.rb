module UMPTG::Fulcrum::Manifest::Validation
  require 'htmlentities'

  class Collection < UMPTG::Object
    MONOGRAPH_FILE_NAME = '://:MONOGRAPH://:'

    # Parameters:
    #   None expected.
    def initialize(args = {})
      super(args)

      @manifest_list = []
      @collection_tree = nil
    end

    def add_manifest(manifest)
      @manifest_list << manifest
    end

    def xml_markup
      manifest_markup_list = []
      @manifest_list.each do |manifest|
        manifest_markup_list << Collection.to_xml(manifest)
      end
      return sprintf(CollectionSchema.MARKUP_COLLECTION, manifest_markup_list.join)
    end

    private

    def self.to_xml(manifest)
      ent_coder = HTMLEntities.new

      monograph_row = nil
      content = {
            :metadata => "",
            :representative => "",
            :resource => ""
            }

      csv_headers = manifest.csv.headers
      if !csv_headers.nil?
        csv_headers.each do |field_name|
          puts "Error: unknown field name \"#{field_name}\"." unless CollectionSchema.header?(field_name)
        end
      end

      manifest.csv.each do |row|
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

                new_value = ent_coder.encode(new_value)
                new_field_value += sprintf("<%s%s>%s</%s>", \
                    metadata_name, attrs, new_value, metadata_name)
              end
              metadata_name += "_list"
              field_value = new_field_value
            end
          when !acceptable_values.nil?
            #new_value = ent_coder.encode(CollectionSchema.normalize(field_value))
            new_value = CollectionSchema.normalize(field_value)
            if metadata_name == 'license'
              new_value = "license_" + new_value
            end
            field_value = "<#{new_value}/>"
          else
            field_value = ent_coder.encode(field_value)
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
        if content_type != :metadata and row.has_key?("noid") and !row["noid"].nil? and !row["noid"].empty?
          attrs += sprintf(" id=\"%s\"", row["noid"])
        end
        content[content_type] += sprintf(CollectionSchema.MARKUP_OBJECT, elem, attrs, collection_list.join, elem)
      end

      if monograph_row.nil?
        monograph_id = manifest.name
      else
        noid = monograph_row["noid"]
        if noid.nil? or noid.empty?
          monograph_id = "monograph"
        else
          monograph_id = noid
        end
      end
      puts "monograph_id:#{monograph_id}"
      #monograph_id = monograph_row == nil ? manifest.name : monograph_row["noid"]
      #monograph_id = @name

      return sprintf(
          CollectionSchema.MARKUP_MONOGRAPH,
          sprintf(" id=\"%s\"", monograph_id),
          content[:metadata],
          content[:representative].empty? ? "" : sprintf(CollectionSchema.MARKUP_REPRESENTATIVES, content[:representative]),
          content[:resource].empty? ? "" : sprintf(CollectionSchema.MARKUP_RESOURCES, content[:resource])
          )
    end
  end
end
