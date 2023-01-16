module UMPTG::Review

  require 'fileutils'

  class MonographDirReviewer < UMPTG::Object
    attr_reader :review_logger, :monograph_dir, :review_dir

    def initialize(args = {})
      super(args)

      @monograph_dir = @properties[:monograph_dir]
      raise "Error: monograph directory \"@monograph_dir\" does not exist." \
                unless File.directory?(@monograph_dir.monograph_dir)

      @review_dir = File.join(@monograph_dir.monograph_dir, "review")

      FileUtils.mkdir_p @review_dir

      @review_logger = UMPTG::Logger.create(
                  logger_file: File.join(@review_dir, @monograph_dir.monograph_id + "_review.log")
               )

    end

    def review(args = {})
      normalize_epub = args.key?(:normalize_epub) ? args[:normalize_epub] : false
      normalize_caption_class = args.key?(:normalize_caption_class) ? args[:normalize_caption_class] : false
      update_css = args.key?(:update_css) ? args[:update_css] : false
      review_resources = args.key?(:review_resources) ? args[:review_resources] : true

      epub_file = @monograph_dir.archived_epub_file
      epub_file = @monograph_dir.epub_file if epub_file.nil? or epub_file.empty?
      if epub_file.nil?
        @review_logger.error("no EPUB file for id #{@monograph_dir.monograph_id}")
        return
      end

      @review_logger.info("*** Review monograph EPUB #{File.basename(epub_file)} ***")

      epub_reviewer = UMPTG::Review::EPUBReviewer.new(
            epub_file: epub_file,
            logger: @review_logger
          )
      epub_reviewer.review(
            normalize: normalize_epub,
            normalize_caption_class: normalize_caption_class,
            update_css: update_css,
            review_options: {
                package: true,
                link: false,
                list: false,
                resources: true,
                table: true,
                accessibility: false
              }
          )

      if epub_reviewer.epub_modified
        epub_normalized_file = File.join(@review_dir, File.basename(epub_file, ".*") + "_normalized.epub")
        #epub_normalized_file = File.join(@review_dir, @monograph_dir.monograph_id + ".epub")
        @review_logger.info("Saving normalized EPUB \"#{File.basename(epub_normalized_file)}.")
        epub_reviewer.epub.save(epub_file: epub_normalized_file)
      end

      if review_resources
        @review_logger.info("*** Review monograph resources ***")

        unless Dir.exists?(@monograph_dir.resources_dir)
          @review_logger.warn("no resources directory for id #{@monograph_dir.monograph_id}")
          return
        end

        resources_manifest = nil
        csv_path = File.join(@monograph_dir.resources_dir, "manifest.csv")
        unless File.exists?(csv_path)
          csv_path_list = Dir.glob(File.join(@monograph_dir.resources_dir, @monograph_dir.isbn + "*.csv"))
          if csv_path_list.empty?
            @review_logger.warn("no resources CSV for id #{@monograph_dir.monograph_id}.")
            return
          else
            @review_logger.warn("multiple resources CSV found for id #{@monograph_dir.monograph_id}") \
                if csv_path_list.count > 1
            csv_path = csv_path_list.first
            @review_logger.info("using resources directory CSV #{File.basename(csv_path)}.")
          end
        end
        resources_manifest = UMPTG::Fulcrum::Manifest::Document.new(csv_file: csv_path)

        total_references = 0
        epub_reviewer.resource_path_list.each do |entry_name,path_list|
          @review_logger.info("#{entry_name}: number of resource references: #{path_list.count}")
          total_references += path_list.count
          path_list.each do |path|
            resource_name = ""
            unless @monograph_dir.manifest.nil?
              fileset = @monograph_dir.manifest.fileset(path)
              if fileset["file_name"].empty? and !resources_manifest.nil?
                fileset = resources_manifest.fileset(File.basename(path))
              end
              resource_name = fileset["file_name"]
            end
            if resource_name.strip.empty?
              @review_logger.warn("resource file not found for reference \"#{File.basename(path)}\".")
            else
              @review_logger.info("resource file #{resource_name} found for reference \"#{File.basename(path)}\".")
            end
          end
        end
        @review_logger.info("total number of resource references: #{total_references}")
      end
    end
  end
end
