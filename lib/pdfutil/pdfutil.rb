class PdfUtil
  JAR_PATH = File.join(__dir__, 'jars', 'PdfUtil-jar-with-dependencies.jar')
  CMD_STR_ALL = "java %s -jar \"%s\" %s"

  def self.optimize(args = {})
    cover_format = args[:cover_format]
    cover_page = args[:cover_page]
    image_format = args[:image_format]
    resize_pct = args[:resize_pct]
    dimen_threshold = args[:dimen_threshold]
    pdf_file_list = args[:pdf_file_list]
    vm_args = args[:vm_args]

    cmd = [ "optimize" ]
    cmd << "-cover_format #{cover_format}" unless cover_format.nil? or cover_format.empty?
    cmd << "-cover_page #{cover_page}" unless cover_page.nil? or cover_format.nil? or cover_format.empty?
    cmd << "-image_format #{image_format}" unless image_format.nil?
    cmd << "-resize_pct #{resize_pct}" unless resize_pct.nil?
    cmd << "-dimen_threshold #{dimen_threshold}" unless dimen_threshold.nil?
    cmd << pdf_file_list
    execute(vm_args, cmd.join(' '))
  end

  def self.execute(vm_args, opts_str)
    java_cmd_str = sprintf(CMD_STR_ALL, vm_args, JAR_PATH, opts_str)
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
