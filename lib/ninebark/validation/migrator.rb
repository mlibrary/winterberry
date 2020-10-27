class Migrator
  @@FMSL_2_FULCRUM_HEADERS = {
          "allow_high_res_display?" => "Allow Fullscreen Display?",
          "rights_granted_creative_commons" => "CC License",
          "primary_creator(s)" => "Creator(s)",
          "externally_hosted_resource" => "External Resource URL",
          "exclusive_to_the_fulcrum_platform" => "Exclusive to Fulcrum",
          "persistent_id" => "DOI"
      }

  def self.fmsl_to_manifest(args = {})
    fmsl_body = args[:fmsl_body]
    fmsl_csv = CSV.parse(
              fmsl_body.join,
              :headers => true,
              :header_converters=> lambda {|f| Migrator.header_convert(f)},
              :return_headers => false
            )

    # Save the resource map CSV file.
    manifest_body = CSV.generate(
            :headers => fmsl_csv.headers
          ) do |csv|

      csv << { "File Name" => Validation.BLANK_ROW_FILE_NAME }

      fmsl_csv.each do |row|
        file_name = row['File Name']

        #next if file_name.nil? or file_name.strip.downcase.start_with?('"this should be') \
        #      or file_name.strip.downcase.start_with?('this should be')
        unless file_name.nil?
          next if file_name.strip.downcase.start_with?('"this should be') \
               or file_name.strip.downcase.start_with?('this should be')
          next if file_name.start_with?(Validation.BLANK_ROW_FILE_NAME)
        end

        unless row['Fulcrum'].nil? or row['Fulcrum'].downcase == 'yes'
          puts "Skipping #{row['File Name']}" unless row['File Name'].nil?
          puts "Skipping row (no file name)" if row['File Name'].nil?
          next
        end

        fulcrum_row = {}
        row.each do |key,val|
          next if key.nil? or key.empty?

          val = nil if val.nil? or val == 0 or val == "0"
          val = nil if val.nil? or (key == "External Resource URL" and val.downcase == 'no')
          fulcrum_row[key] = val
        end
        if fulcrum_row['Permissions Expiration Date'].nil? or fulcrum_row['Permissions Expiration Date'] == '1900-01-00'
          fulcrum_row['Permissions Expiration Date'] = nil
          #fulcrum_row['After Expiration: Allow Display?'] = nil
          #fulcrum_row['After Expiration: Allow Download?'] = nil
        end
        csv << fulcrum_row
      end
    end
    return CSV.parse(
                manifest_body,
                :headers => fmsl_csv.headers,
                :return_headers => false
          )
  end

  private

  def self.header_convert(header)
    #nh = header.strip.downcase.gsub(/[ \-\/]+/, '_')
    nh = CollectionSchema.normalize(header)
    return @@FMSL_2_FULCRUM_HEADERS[nh] if @@FMSL_2_FULCRUM_HEADERS.has_key?(nh)
    return header.strip
  end
end
