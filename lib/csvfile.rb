require 'csv'

class CSVFile
  def self.read(args = {})
    if args.has_key?(:csv_path)
      csv_path = File.expand_path(args[:csv_path])
      csv_body = File.read(csv_path)
    else
      csv_body = options[:csv_body]
    end
    return nil if csv_body == nil or csv_body.empty?

    begin
      csv_data = CSV.parse(
                csv_body,
                :headers => true,
                :return_headers => false)
     #          :header_converters => lambda { |h| h.downcase.gsub(' ', '_') })
     #          :headers => true, :converters => :all,
    rescue Exception => e
      puts e.message
      return nil
    end

    return csv_data
  end
end
