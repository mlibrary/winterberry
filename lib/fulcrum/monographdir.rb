module UMPTG::Fulcrum

  require_relative "manifest"

  #@@DEFAULT_PUBLISHER_DIR = OS.windows? ? "s:/Information\ Management/Fulcrum" : "/mnt/umptmm"
  @@DEFAULT_DIR = "s:/Information\ Management/Fulcrum"
  @@DEFAULT_PUBLISHER = "UMP"

  class MonographDir < UMPTG::Object

    attr_accessor :logger
    attr_reader :archived_epub_file, :epub_file, :fmsl, :fmsl_file, \
          :isbn, :manifest, :monograph_dir, :monograph_id,\
          :publisher, :publisher_dir, :processing_dir, :resources_dir

    def initialize(args = {})
      super(args)

      @logger = @properties.key?(:logger) ? @properties[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)
      @publisher = @properties.key?(:publisher) ? \
                 @properties[:publisher] : UMPTG::Fulcrum.DEFAULT_PUBLISHER

      @publisher_dir = @properties.key?(:publisher_dir) ? \
                @properties[:publisher_dir] : File.join(UMPTG::Fulcrum.DEFAULT_DIR, @publisher)

      @manifest = nil
      @fmsl_file = nil
      @fmsl = nil
      @processing_dir = nil

      case
      when @properties.key?(:monograph_dir)
        @monograph_dir = File.expand_path(@properties[:monograph_dir], @publisher_dir)
        if File.directory?(@monograph_dir)
          @logger.info("using monograph directory #{@monograph_dir}")
        else
          @logger.error("invalid monograph directory #{@monograph_dir}")
          @monograph_dir = nil
        end

      when @properties.key?(:monograph_id)
        @monograph_id = @properties[:monograph_id]
        if @monograph_id.nil? or @monograph_id.strip.empty?
          @logger.error("no monograph ID specified")
        else
          @manifest = UMPTG::Fulcrum::Manifest::Document.new(
                      fulcrum_host: @properties[:fulcrum_host],
                      monograph_id: @monograph_id
                  )
          monograph_dir_list = []
=begin
          if @manifest.nil?
            # Find the ebook source folder. Look for a directory
            # using the monograph id.
            monograph_dir_list = Dir.glob(File.join(@publisher_dir, @publisher, "#{@monograph_id}_*"))
          else
            # From the manifest, determine the ebook ISBN without dashes.
            ebook_isbn = @manifest.isbn["open access"]
            ebook_isbn = @manifest.isbn["ebook"] if ebook_isbn.nil?

            unless ebook_isbn.nil? or ebook_isbn.strip.empty?
              ebook_isbn = ebook_isbn.strip.gsub('-', '')
              #monograph_dir_list = Dir.glob(File.join(@publisher_dir, @publisher, "#{ebook_isbn}_*"))
              monograph_dir_list = Dir.glob(File.join(@publisher_dir, "#{ebook_isbn}_*"))
            end
            @isbn = ebook_isbn
          end
=end
          unless @manifest.nil?
            # From the manifest, determine the ebook ISBN without dashes.
            ebook_isbn = @manifest.isbn["open access"]
            ebook_isbn = @manifest.isbn["ebook"] if ebook_isbn.nil?
            ebook_isbn = ebook_isbn.nil? ? "" : ebook_isbn.strip

            unless ebook_isbn.empty?
              ebook_isbn = ebook_isbn.strip.gsub('-', '')
              #monograph_dir_list = Dir.glob(File.join(@publisher_dir, @publisher, "#{ebook_isbn}_*"))
              monograph_dir_list = Dir.glob(File.join(@publisher_dir, "#{ebook_isbn}_*"))
            end
            @isbn = ebook_isbn
          end

          # Find the ebook source folder. Look for a directory
          # using the monograph id.
          monograph_dir_list = Dir.glob(File.join(@publisher_dir, @publisher, "#{@monograph_id}_*")) if monograph_dir_list.empty?
          monograph_dir_list = Dir.glob(File.join(@publisher_dir, @monograph_id)) if monograph_dir_list.empty?
          monograph_dir_list = Dir.glob(File.join(@publisher_dir, "#{@monograph_id}_*")) if monograph_dir_list.empty?
          @monograph_dir = monograph_dir_list.empty? ? nil : monograph_dir_list.first
        end
      else
        raise "either :monograph_dir or :monograph_id must be specified."
      end

      unless @monograph_dir.nil?
        # Determine if the resources directory exists.
        resources_dir_list = Dir.glob(File.join(@monograph_dir, "[Rr]esources"))
        @resources_dir = resources_dir_list.empty? ? File.join(@monograph_dir, "Resources") : resources_dir_list.first

        # Find the monograph processing directory and insure that it exists.
        @processing_dir = File.join(@monograph_dir, "resource_processing")

        # If the resource Fulcrum metadata CSV exists, then load it.
        if @fmsl.nil?
          @fmsl_file = File.join(@resources_dir, "manifest.csv")
          unless File.file?(@fmsl_file)
            @fmsl_file = nil
            path_list = Dir.glob(File.join(@resources_dir, "*.csv"))
            if path_list.empty?
              @logger.warn("no resources CSV for id #{@monograph_id}.")
            else
              @fmsl_file = path_list.first
              @logger.warn("multiple resources CSV found for id #{@monograph_id}.") \
                    if path_list.count > 1
              @logger.warn("using CSV #{File.basename(@fmsl_file)}")
            end
          end

          if @fmsl_file.nil? or !File.file?(@fmsl_file)
            @logger.warn("no manifest file found")
          else
            @fmsl = UMPTG::Fulcrum::Manifest::Document.new(
                        csv_file: @fmsl_file,
                        convert_headers: false
                    )
          end
        end

        # Find the epub file name and determine whether it exists.
        if @manifest.nil?
          epub_row = @fmsl.representative_row(kind: "epub") unless @fmsl.nil?
        else
          epub_row = @manifest.representative_row(kind: "epub")
        end
        if epub_row.nil?
          epub_list = Dir.glob(File.join(@monograph_dir, "*.epub"))
          raise "no monograph EPUB found" if epub_list.empty?
          epub_file_name = epub_list.first
          @epub_file = epub_list.first
        else
          epub_file_name = epub_row['file_name']
          @epub_file = File.expand_path(File.join(@monograph_dir, epub_file_name))
        end
        archive_dir = File.join(@monograph_dir, "archive")
        archived_epub_list = Dir.glob(File.join(archive_dir, "*.epub"))
        @archived_epub_file = archived_epub_list.last
      end
    end
  end

  def self.DEFAULT_PUBLISHER
    return @@DEFAULT_PUBLISHER
  end

  def self.DEFAULT_DIR
    return @@DEFAULT_DIR
  end
end
