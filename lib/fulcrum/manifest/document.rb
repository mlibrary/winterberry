module UMPTG::Fulcrum::Manifest
  @@BLANK_ROW_FILE_NAME = "***row left intentionally blank***"

  @@MONOGRAPH_FILE_NAME = '://:MONOGRAPH://:'

  class Document < UMPTG::Object
    attr_reader :name, :noid, :csv, :monograph_row, :isbn

    def initialize(args = {})
      super(args)

      @name = @properties[:name]
      csv_body = @properties[:csv_body]
      fail "Error: manifest is empty" if csv_body.nil? or csv_body.empty?

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

      @monograph_row = @csv.find {|row| row['file_name'] == @@MONOGRAPH_FILE_NAME }
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
        file_name_base = File.basename(file_name, ".*")
        fileset_row = @csv.find {|row| !row['file_name'].nil? and File.basename(row['file_name'], ".*") == file_name_base }
        return fileset_row unless fileset_row.nil?
      end

      return {
                "noid" => "",
                "resource_name" => "",
                "link" => "",
                "embed_code" => ""
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

  def self.BLANK_ROW_FILE_NAME
    return @@BLANK_ROW_FILE_NAME
  end

  def self.MONOGRAPH_FILE_NAME
    return @@MONOGRAPH_FILE_NAME
  end
end
