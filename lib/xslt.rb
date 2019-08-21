class XSLT
  JAR_PATH = File.join(__dir__, 'jars', 'Saxon-HE-9.9.1-1.jar')
  CMD_STR = "java -jar \"%s\" -xsl:\"%s\" -s:\"%s\" -o:\"%s\" %s"

  def self.transform(args)
    xsl_path = args[:xslpath]
    src_path = args[:srcpath]
    dest_path = args[:destpath]
    parameters = args[:parameters]

    parameters_str = ""
    parameters.each { |key, val| parameters_str += " #{key}=\"#{val}\""} unless parameters == nil
    cmd_str = sprintf(CMD_STR, JAR_PATH, xsl_path, src_path, dest_path, parameters_str)
    puts cmd_str
    STDOUT.flush

    ok = system(cmd_str)
    status = $?

    case ok
    when true
    else
      puts "Transform failed (status = #{status})"
    end
  end
end
