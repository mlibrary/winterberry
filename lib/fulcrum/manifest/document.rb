module UMPTG::Fulcrum::Manifest
  @@BLANK_ROW_FILE_NAME = "***row left intentionally blank***"
  #@@BLANK_ROW_FILE_NAME = "*** row intentionally left blank ***"

  @@MONOGRAPH_FILE_NAME = '://:MONOGRAPH://:'

  class Document < UMPTG::Object
    attr_reader :name, :noid, :csv, :monograph_row, :isbn

    def initialize(args = {})
      super(args)

      @name = @properties[:name]

      case
      when @properties.key?(:csv_body)
        csv_body = @properties[:csv_body]
      when @properties.key?(:csv_file)
        csv_file = @properties[:csv_file]
        raise "Error: invalid CSV file path #{csv_file}" \
              if csv_file.nil? or csv_file.strip.empty? or !File.exists?(csv_file)
        csv_body = File.read(csv_file)
      when @properties.key?(:monograph_id)
        service = UMPTG::Services::Heliotrope.new(
                        :fulcrum_host => @properties[:fulcrum_host]
                      )
        csv_body = service.monograph_export(identifier: @properties[:monograph_id])
      else
        # No content specified
        csv_body = nil
      end

      raise "Error: manifest is empty" if csv_body.nil? or csv_body.strip.empty?

      begin
        @csv = CSV.parse(
                  csv_body,
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

    def representative_row(args = {})
      return nil unless args.has_key?(:kind)

      kind = args[:kind]
      row = @csv.find {|row| row['representative_kind'] == kind.downcase }
      raise "Error: representative #{kind} not found" if row.nil?
      return row
    end

    def fileset(file_name)
      if file_name != nil
        file_name_base = File.basename(file_name, ".*").downcase
        fileset_row = @csv.find {|row| !row['file_name'].nil? and File.basename(row['file_name'], ".*").downcase == file_name_base }
        return fileset_row unless fileset_row.nil?
      end

      return {
                "noid" => "",
                "file_name" => "",
                "resource_name" => "",
                "link" => "",
                "embed_code" => ""
             }
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
