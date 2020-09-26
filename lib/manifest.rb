
require 'csv'

require_relative File.join('services', 'heliotrope')

module UMPTG
  class Manifest
    attr_reader :noid, :csv_path, :csv

    @@MONOGRAPH_FILE_NAME = '://:MONOGRAPH://:'

    def initialize(args = {})
      @noid = args[:noid]
      @csv_path = args[:csv_path]
      @fulcrum_host = args[:fulcrum_host] if args.key?(:fulcrum_host)

      fail "Both a NOID an path supplied." if @noid.nil? and @csv_path.nil?
      fail "Either a NOID or a path must be supplied." unless @noid.nil? or @csv_path.nil?

      @csv = nil
      @monograph_row = nil
      @isbns = {}
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

    def load
      return unless @csv.nil?

      service = UMPTG::Services::Heliotrope.new(
                      :fulcrum_host => @fulcrum_host
                    )
      csv_body = service.monograph_noid_export(@noid) unless @noid.nil?
      csv_body = File.read(@csv_path) unless @csv_path.nil?
      fail "Unable to load manifest." if csv_body.nil?

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
