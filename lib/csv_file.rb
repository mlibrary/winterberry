require 'csv'

class CSVFile
  def self.read(options = {})
    csv_body = options[:csv_body]

    if csv_body == nil or csv_body.empty?
      return nil
    end

    begin
      csv_data = CSV.parse(
                csv_body,
                :headers => true,
                :return_headers => false,
                :header_converters => lambda { |h| h.downcase.gsub(' ', '_') })
     #          :headers => true, :converters => :all,
    rescue Exception => e
      puts e.message
      return nil
    end

    return csv_data
  end

  def self.read_file(options = {})
    csv_path = options[:csv_path]
    if csv_path == nil or csv_path.empty?
      return nil
    end
    
    options[:csv_body] = File.read(File.expand_path(csv_path))
    return read(options)
  end
end
