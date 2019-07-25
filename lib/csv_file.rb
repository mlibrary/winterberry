require 'csv'

class CSVFile
  def self.read_file(options = {})
    csv_path = options[:csv_path]
    if csv_path == nil or csv_path.empty?
      return nil
    end
    
    csv_path = File.expand_path(csv_path)
    begin
      csv_data = CSV.parse(
                File.read(csv_path),
                :headers => true,
                :header_converters => lambda { |h| h.downcase.gsub(' ', '_') })
     #          :headers => true, :converters => :all,
    rescue Exception => e
      puts e.message
      return nil
    end

    return csv_data
  end
end
