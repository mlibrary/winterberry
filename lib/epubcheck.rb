class EpubCheck
  JAR_PATH = File.join(__dir__, 'jars', 'epubcheck-jar-with-dependencies.jar')
  CMD_STR = "java -jar \"%s\" -q -o \"%s\" \"%s\""

  def self.check_file(args)
    epub_file = args[:epubfile]
    log_file = args[:logfile]

    cmd_str = sprintf(CMD_STR, JAR_PATH, log_file, epub_file)
    puts cmd_str
    STDOUT.flush

    ok = system(cmd_str)
    status = $?

    case ok
    when true
    else
      #puts "epubcheck failed (status = #{status})"
    end
  end
end
