module UMPTG::Manifest
  class Document
    attr_reader :name, :noid, :csv

    @@MONOGRAPH_FILE_NAME = '://:MONOGRAPH://:'

    def initialize(args = {})
      @name = args[:name]
      csv_body = args[:csv_body]
      fail "Error: manifest is empty" if csv_body.nil? or csv_body.empty?

      @monograph_row = nil
      @isbns = {}

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
    end

    def monograph_row
      find_monograph_row()

      do_raise("Error: no CSV monograph row") if @monograph_row == nil
      return @monograph_row
    end

    def representative_row(args = {})
      return nil unless args.has_key?(:kind)

      kind = args[:kind]
      row = @csv.find {|row| row['representative_kind'] == kind.downcase }
      do_raise("Error: representative #{kind} not found") if row.nil?
      return row
    end

    def isbn(args = {})
      return nil unless args.has_key?(:format)

      format = args[:format]
      parse_isbns()
      return @isbns[format]
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

    def isbns
      parse_isbns()
      do_raise("Error: no isbns found for noid #{@noid}") if @isbns.nil? or @isbns.empty?
      return @isbns
    end

    private

    def find_monograph_row
      load()

      # Find monograph row.
      @monograph_row = @csv.find {|row| row['noid'] == @noid } unless @noid.nil?
      @monograph_row = @csv.find {|row| row['file_name'] == @@MONOGRAPH_FILE_NAME } unless @csv_path.nil?
    end

    def parse_isbns
      return unless @isbns.empty?

      find_monograph_row()

      isbns_property = @monograph_row['isbn(s)']
      unless isbns_property.nil? or isbns_property.empty?
        isbns_list = isbns_property.split(';').each do |isbn|
          list = isbn.strip.downcase.match('([0-9\-]+)[ ]+\(([^\)]+)\)')
          unless list.nil?
            @isbns[list[2]] = list[1]
          end
        end
      end
    end

    def do_raise(msg)
      raise "#{msg} for noid #{@noid}" unless @noid.nil?
      raise "#{msg} for path #{File.basename(@csv_path)}" unless @csv_path.nil?
    end
  end
end
