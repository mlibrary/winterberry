module UMPTG
  require 'csv'

  require_relative 'manifest'

  class FMSL
    @@FMSL_2_FULCRUM_HEADERS = {
            "allow_high_res_display?" => "Allow Fullscreen Display?",
            "rights_granted_creative_commons" => "CC License",
            "primary_creator(s)" => "Creator(s)",
            "externally_hosted_resource" => "External Resource URL",
            "exclusive_to_the_fulcrum_platform" => "Exclusive to Fulcrum",
            "persistent_id" => "DOI"
        }

    def self.load(args = {})
      fmsl_file = args[:fmsl_file]

      # Normalize the FMSL into Fulcrum metadata.
      # Remove line that have either an empty "File Name"
      # or "File Name" == 0
      fmsl_body = File.open(fmsl_file).readlines.delete_if { |line|
        line.strip.empty? \
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

        csv << { "File Name" => Manifest.BLANK_ROW_FILE_NAME }

        fmsl_csv.each do |row|
          file_name = row['File Name']

          #next if file_name.nil? or file_name.strip.downcase.start_with?('"this should be') \
          #      or file_name.strip.downcase.start_with?('this should be')
          unless file_name.nil?
            next if file_name.strip.downcase.start_with?('"this should be') \
                 or file_name.strip.downcase.start_with?('this should be')
            next if file_name.start_with?(Manifest.BLANK_ROW_FILE_NAME)
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
      nh = UMPTG::Manifest::Validation::CollectionSchema.normalize(header)
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
