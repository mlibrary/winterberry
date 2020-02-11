class PdfUtil
  JAR_PATH = File.join(__dir__, 'jars', 'PdfUtil-jar-with-dependencies.jar')
  CMD_STR_ALL = "java -jar \"%s\" %s"

  def self.optimize(args = {})
    compression_level = args[:compression_level]
    cover_format = args[:cover_format]
    cover_page = args[:cover_page]
    delete_dir = args[:delete_dir]
    image_format = args[:image_format]
    resize_pct = args[:resize_pct]
    dimen_threshold = args[:dimen_threshold]
    pdf_file_list = args[:pdf_file_list]

    cmd = [ "optimize" ]
    cmd << "-delete_dir" if delete_dir
    cmd << "-cover_format #{cover_format}" unless cover_format.nil? or cover_format.empty?
    cmd << "-cover_page #{cover_page}" unless cover_page.nil? or cover_format.nil? or cover_format.empty?
    cmd << "-image_format #{image_format}" unless image_format.nil?
    cmd << "-compression_level #{compression_level}" unless compression_level.nil?
    cmd << "-resize_pct #{resize_pct}" unless resize_pct.nil?
    cmd << "-dimen_threshold #{dimen_threshold}" unless dimen_threshold.nil?
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
