module UMPTG
  require 'logger'

  class Logger
    def self.create(args = {})
      case
      when args.key?(:logger_file)
        logger_file = args[:logger_file]
        logger_fp = File.open(logger_file, File::WRONLY | File::TRUNC | File::CREAT)
      when args.key?(:logger_fp)
        logger_fp = args[:logger_fp]
      else
        logger_fp = StringIO.new
      end

      logger = ::Logger.new(logger_fp)
      logger.formatter = proc do |severity, datetime, progname, msg|
        "#{severity}: #{msg}\n"
      end

      return logger
    end
  end
end
