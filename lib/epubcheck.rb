class EpubCheck
  JAR_PATH = File.join(__dir__, 'jars', 'epubcheck-jar-with-dependencies.jar')
  CMD_STR_EPUB = "java -jar \"%s\" -q -o \"%s\" \"%s\""
  CMD_STR_EPUBDIR = "java -jar \"%s\" -q -o \"%s\" -mode exp \"%s\""

  def self.check_file(args)
    epub_path = args[:epubpath]
    log_file = args[:logfile]

    cmd_str = File.directory?(epub_path) ? CMD_STR_EPUBDIR : CMD_STR_EPUB
    java_cmd_str = sprintf(cmd_str, JAR_PATH, log_file, epub_path)
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
