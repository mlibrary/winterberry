module UMPTG::Review
  class EPUBProcessor < UMPTG::Object
    attr_reader :epub, :epub_modified, :logger, :action_map

    def initialize(args = {})
      super(args)

      # Determine the EPUB to use.
      case
      when @properties.key?(:epub_file)
        @epub = UMPTG::EPUB::Archive.new(epub_file: @properties[:epub_file])
      when @properties.key?(:epub)
        @epub = @properties[:epub]
      else
        raise "Error no EPUB specified"
      end

      # Init log file. Use specified path or STDOUT.
      case
      when @properties.key?(:logger_file)
        logger_file = @properties[:logger_file]
        @logger = UMPTG::Logger.create(
                          logger_fp: File.open(logger_file, File::WRONLY | File::TRUNC | File::CREAT)
                      )
      when @properties.key?(:logger)
        @logger = @properties[:logger]
      else
        @logger = UMPTG::Logger.create(
                          logger_fp: STDOUT
                     )
      end

      @action_map = {}
      @epub_modified = false
    end
  end
end