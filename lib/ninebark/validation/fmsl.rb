class FMSL

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
end
