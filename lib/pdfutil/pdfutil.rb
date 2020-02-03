class PdfUtil
  JAR_PATH = File.join(__dir__, 'jars', 'PdfUtil-jar-with-dependencies.jar')
  CMD_STR_ALL = "java -jar \"%s\" %s"

  def self.optimize(args = {})
    cover_format = args[:cover_format]
    resize_pct = args[:resize_pct]
    dimen_threshold = args[:dimen_threshold]
    pdf_file_list = args[:pdf_file_list]

    cmd = [ "optimize" ]
    if cover_format != nil
      cmd << "-cover #{cover_format}"
    end
    cmd << resize_pct
    cmd << dimen_threshold
    cmd << pdf_file_list
    execute(cmd.join(' '))
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
