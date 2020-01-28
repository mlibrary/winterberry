class PdfUtil
  JAR_PATH = File.join(__dir__, 'jars', 'PdfUtil-jar-with-dependencies.jar')
  CMD_STR_ALL = "java -jar \"%s\" %s"

  def self.optimize(args = {})
    resize_pct = args[:resize_pct]
    dimen_threshold = args[:dimen_threshold]
    pdf_file_list = args[:pdf_file_list]
    execute("optimize #{resize_pct} #{dimen_threshold} #{pdf_file_list.join(' ')}")
  end

  def self.execute(opts_str)
    java_cmd_str = sprintf(CMD_STR_ALL, JAR_PATH, opts_str)
    puts java_cmd_str
    STDOUT.flush
    #return

    ok = system(java_cmd_str)
    status = $?

    case ok
    when true
    else
      puts "pdfutil failed (status = #{status})"
    end
  end
end
