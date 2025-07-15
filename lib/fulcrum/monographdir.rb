module UMPTG::Fulcrum

  require_relative File.join("..", "fmsl")

  class MonographDir < UMPTG::Object

    attr_accessor :logger, :monograph_dir, :monograph_id

    def initialize(args = {})
      super(args)

      @logger = @properties.key?(:logger) ? @properties[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)

      @monograph_dir = @properties[:monograph_dir]
      raise "no monograph directory specified" \
          if @monograph_dir.nil? or @monograph_dir.strip.empty?
      @monograph_dir = File.expand_path(@properties[:monograph_dir])
      raise "invalid monograph directory #{@monograph_dir}" \
          unless File.directory?(@monograph_dir)

      case
      when @properties.key?(:monograph_id)
        @monograph_id = @properties[:monograph_id]
      else
        @monograph_id = File.basename(@monograph_dir, ".*")[0..12]
      end

      @manifest_list = nil
      @manifest_file = @properties[:manifest_file]

      @epub_file = nil
      @resources_dir = nil
      @fmsl_file = nil
      @fmsl = nil
    end

    def manifests()
      if @manifest_list.nil?
        if @manifest_file.nil?
          service = UMPTG::Services::Heliotrope.new(
                          :fulcrum_host => @properties[:fulcrum_host]
                        )
          manifest_body_list = service.monograph_export(identifier: @monograph_id)
        else
          manifest_body_list = {
                @monograph_id => [ File.read(@manifest_file) ]
              }
        end

        @manifest_list = []
        manifest_body_list.values.each do |mb_list|
          @logger.warn("#{mb_list.count} manifests found for monograph ID #{@monograph_id}.") \
                if mb_list.count > 1
          mb_list.each do |mb|
            m = UMPTG::Fulcrum::Manifest::Document.new(
                        csv_body: mb,
                        convert_headers: false
                    )
            @manifest_list << m unless m.nil?
          end
        end
      end
      return @manifest_list
    end

    def epub_file
      @epub_file = Dir.glob(File.join(@monograph_dir, "*.epub")).first || nil \
            if @epub_file.nil?
      return @epub_file
    end

    def resources_dir()
      @resources_dir = Dir.glob(File.join(@monograph_dir, "[Rr]esources")).first \
            if @resources_dir.nil?
      return @resources_dir
    end

    def fmsl_file()
      if @fmsl_file.nil?
        unless resources_dir().nil?
          f = File.join(resources_dir(), "manifest.csv")
          unless File.file?(f)
            f_list = Dir.glob(File.join(@resources_dir, "#{@monograph_id}*.{xlsx,csv}"))
            f_list = Dir.glob(File.join(@resources_dir, "*.{xlsx,csv}")) if f_list.empty?
            unless f_list.empty?
              @logger.warn("multiple resource spreadsheets found for monograph directory #{@monograph_dir}.") \
                    if f_list.count > 1
              f = f_list.select {|p| File.extname(p).downcase == ".csv" }.first || f_list.first
            end
          end
          @fmsl_file = f
          @logger.info("using CSV #{File.basename(@fmsl_file)}")
        end
      end
      return @fmsl_file
    end

    def fmsl()
      if @fmsl.nil?
        f = fmsl_file()
        unless f.nil?
          fmsl_csv = UMPTG::FMSL.to_manifest(fmsl_body: UMPTG::FMSL.load(fmsl_file: f))
          fm = UMPTG::Fulcrum::Manifest::Document.new(
                      csv_body: fmsl_csv.to_s,
                      convert_headers: false
                  )
        end
        @fmsl = fm unless fm.nil?
      end
      return @fmsl
    end
  end
end
