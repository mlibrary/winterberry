module UMPTG
  require 'csv'
  require 'xsv'

  require_relative File.join('fulcrum', 'manifest')

  class FMSL
    @@FMSL_2_FULCRUM_HEADERS = {
            "allow_high_res_display?" => "Allow Fullscreen Display?",
            "rights_granted_creative_commons" => "CC License",
            "rights_granted_-_creative" => "CC License",
            "primary_creator(s)" => "Creator(s)",
            "primary_creator" => "Creator(s)",
            "externally_hosted_resource" => "External Resource URL",
            "exclusive_to_the_fulcrum_platform" => "Exclusive to Fulcrum",
            "exclusive_to_the_fulcrum" => "Exclusive to Fulcrum",
            "exclusive_to_fulcrum?" => "Exclusive to Fulcrum",
            "persistent_id" => "DOI",
            "legacy_id" => "Identifier(s)"
        }

    def self.load(args = {})
      fmsl_file = args[:fmsl_file]

      if File.extname(fmsl_file) == ".xlsx"
        x = Xsv::Workbook.open(fmsl_file)
        sheet = x.sheets_by_name("Project Data").first
        fmsl_body_list = []
        sheet.each do |row|
          next if row[0].nil?
          fmsl_body_list << CSV.generate_line(row)
        end
      else
        fmsl_body_list = File.open(fmsl_file).readlines
      end

      # Normalize the FMSL into Fulcrum metadata.
      # Remove line that have either an empty "File Name"
      # or "File Name" == 0
      fmsl_body = fmsl_body_list.delete_if { |line|
      #fmsl_body = File.open(fmsl_file).readlines.delete_if { |line|
        line.strip.empty? \
          or line.strip.start_with?(',,,') \
          or line.strip.start_with?('0,') \
          or line.strip.downcase.start_with?('"in any columns') \
          or line.strip.downcase.start_with?('in any columns') \
          or line.strip.downcase.start_with?('primary data')
      }
      return fmsl_body
    end

    def self.to_manifest(args = {})
      fmsl_body = args[:fmsl_body]
      fmsl_csv = CSV.parse(
                fmsl_body.join,
                :headers => true,
                :header_converters=> lambda {|f| FMSL.header_convert(f)},
                :return_headers => false
              )

      # Save the resource map CSV file.
      manifest_body = CSV.generate(
              :headers => fmsl_csv.headers
            ) do |csv|

        csv << { "File Name" => UMPTG::Fulcrum::Manifest.BLANK_ROW_FILE_NAME }

        fmsl_csv.each do |row|
          file_name = row['File Name']

          #next if file_name.nil? or file_name.strip.downcase.start_with?('"this should be') \
          #      or file_name.strip.downcase.start_with?('this should be')
          unless file_name.nil?
            next if file_name.strip.downcase.start_with?('"this should be') \
                 or file_name.strip.downcase.start_with?('this should be')
            next if UMPTG::Fulcrum::Manifest.blank_row_name?(file_name)
          end

          unless row['Fulcrum'].nil? or row['Fulcrum'].downcase == 'yes'
            if row['File Name'].nil?
              puts "Skipping row (no file name), Fulcrum != 'yes'"
            else
              puts "Skipping #{row['File Name']}, Fulcrum != 'yes'"
            end
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
      nh = UMPTG::Fulcrum::Manifest::Validation::CollectionSchema.normalize(header)
      return @@FMSL_2_FULCRUM_HEADERS[nh] if @@FMSL_2_FULCRUM_HEADERS.has_key?(nh)
      return header.strip
    end

=begin
    def self.parse(args = {})
      fmsl_body = args[:fmsl_body]
      convert_headers = args.has_key?(:convert_headers) ? args[:convert_headers] : false

      # Create the CSV object.
      begin
        if convert_headers
          fmsl_csv = CSV.parse(
                    fmsl_body.join,
                    :headers => true,
                    :header_converters=> lambda {|f| f.strip.downcase.gsub(/[ \-\/]+/, '_')},
                    :return_headers => false
                    )
        else
          fmsl_csv = CSV.parse(
                    fmsl_body.join,
                    :headers => true,
                    :header_converters=> lambda {|f| f.strip},
                    :return_headers => false
                    )
        end
      rescue Exception => e
        puts e.message
        return nil
      end

      return fmsl_csv
    end
=end
  end
end
