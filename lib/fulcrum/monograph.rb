module UMPTG::Fulcrum
  require "fileutils"

  class Monograph < UMPTG::Object

    #@@DEFAULT_PUBLISHER_DIR = OS.windows? ? "s:/Information\ Management/Fulcrum" : "/mnt/umptmm"
    @@DEFAULT_PUBLISHER_DIR = "s:/Information\ Management/Fulcrum"
    @@DEFAULT_PUBLISHER = "UMP"

    attr_reader :epub_file, :isbn, :manifest, :monograph_dir, :monograph_id,\
          :publisher_dir, :resources_dir, :review_dir

    def initialize(args = {})
      super(args)

      @publisher = @properties.key?(:publisher) ? \
                 @properties[:publisher] : Monograph.DEFAULT_PUBLISHER

      @publisher_dir = @properties.key?(:publisher_dir) ? \
                @properties[:publisher_dir] : File.join(Monograph.DEFAULT_PUBLISHER_DIR, @publisher)

      case
      when @properties.key?(:monograph_dir)
        @monograph_dir = File.expand_path(@properties[:monograph_dir], @publisher_dir)
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
          if @manifest.nil?
            # Find the ebook source folder. Look for a directory
            # using the monograph id.
            monograph_dir_list = Dir.glob(File.join(@publisher_dir, @publisher, "#{@monograph_id}_*"))
          else
            # From the manifest, determine the ebook ISBN without dashes.
            ebook_isbn = manifest.isbn["open access"]
            ebook_isbn = manifest.isbn["ebook"] if ebook_isbn.nil?

            unless ebook_isbn.nil? or ebook_isbn.strip.empty?
              ebook_isbn = ebook_isbn.strip.gsub('-', '')
              monograph_dir_list = Dir.glob(File.join(@publisher_dir, @publisher, "#{ebook_isbn}_*"))
            end
            @isbn = ebook_isbn
          end
          @monograph_dir = monograph_dir_list.empty? ? nil : monograph_dir_list.first
        end
      else
        raise "either :monograph_dir or :monograph_id must be specified."
      end

      unless @monograph_dir.nil?
        # Determine if the resources directory exists.
        resources_dir_list = Dir.glob(File.join(@monograph_dir, "[Rr]esources"))
        @resources_dir = resources_dir_list.empty? ? File.join(@monograph_dir, "Resources") : resources_dir_list.first

        # Find the epub file name and determine whether it exists.
        epub_row = @manifest.representative_row(kind: "epub")
        epub_file_name = epub_row['file_name']
        @epub_file = File.join(@monograph_dir, epub_file_name)
      end
    end

    def self.DEFAULT_PUBLISHER
      return @@DEFAULT_PUBLISHER
    end

    def self.DEFAULT_PUBLISHER_DIR
      return @@DEFAULT_PUBLISHER_DIR
    end
  end
end
