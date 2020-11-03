module UMPTG
  class XSLT
    @@XSL_DIR = File.join(__dir__, 'xsl')
    @@JAR_PATH = File.join(__dir__, 'jars', 'Saxon-HE-9.9.1-1.jar')
    @@CMD_STR = "java -jar \"%s\" -xsl:\"%s\" -s:\"%s\" %s"
    @@CMD_STR_DEST = "java -jar \"%s\" -xsl:\"%s\" -s:\"%s\" -o:\"%s\" %s"

    def self.transform(args)
      xsl_path = args[:xslpath]
      src_path = args[:srcpath]
      dest_path = args[:destpath]
      parameters = args[:parameters]

      parameters_str = ""
      parameters.each { |key, val| parameters_str += " #{key}=\"#{val}\""} unless parameters == nil
      if dest_path == nil or dest_path.strip.empty?
        cmd_str = sprintf(@@CMD_STR, @@JAR_PATH, xsl_path, src_path, parameters_str)
      else
        cmd_str = sprintf(@@CMD_STR_DEST, @@JAR_PATH, xsl_path, src_path, dest_path, parameters_str)
      end
      puts cmd_str
      STDOUT.flush

      ok = system(cmd_str)
      status = $?

      case ok
      when true
      else
        puts "Transform failed (status = #{status})"
      end
      return ok
    end

    def self.XSL_DIR
      return @@XSL_DIR
    end
  end
end