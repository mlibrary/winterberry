class EpubCheck
  JAR_PATH = File.join(__dir__, 'epubcheck', 'epubcheck.jar')
  CMD_STR_EPUB = "-q -o \"%s\" \"%s\""
  CMD_STR_EPUBDIR = "-q -o \"%s\" -mode exp \"%s\""
  CMD_STR_ALL = "java -jar \"%s\" %s"

  def self.check_file(args)
    epub_path = args[:epubpath]
    log_file = args[:logfile]

    cmd_str = File.directory?(epub_path) ? CMD_STR_EPUBDIR : CMD_STR_EPUB
    java_cmd_str = sprintf(cmd_str, log_file, epub_path)
    execute(java_cmd_str)
  end

  def self.invoke(args = [])
    opts_str = args.count == 0 ? "-h" : args.join(' ')
    execute(opts_str)
  end

  def self.execute(opts_str)
    java_cmd_str = sprintf(CMD_STR_ALL, JAR_PATH, opts_str)
    puts java_cmd_str
    STDOUT.flush

    ok = system(java_cmd_str)
    status = $?

    case ok
    when true
    else
      #puts "epubcheck failed (status = #{status})"
    end
  end

end
