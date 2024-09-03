module UMPTG
  require 'open3'
  require 'nokogiri'

  require_relative File.join("logger")

  class XSLT
    @@XSL_DIR = File.join(__dir__, 'xsl')
    @@JAR_PATH = File.join(__dir__, 'jars', 'Saxon-HE-9.9.1-1.jar')
    @@CMD_STR = "java -jar \"%s\" -xsl:\"%s\" -s:\"%s\" %s"
    @@CMD_STR_DEST = "java -jar \"%s\" -xsl:\"%s\" -s:\"%s\" -o:\"%s\" %s"

    def self.transform(args)
      xsl_path = args[:xslpath]
      src_doc = args[:srcdoc]
      src_path = args[:srcpath]
      dest_path = args[:destpath]
      logger = args[:logger]
      parameters = args[:parameters]

      if logger.nil?
        logger = UMPTG::Logger.create(logger_fp: STDOUT) if logger.nil?
        do_flush = true
      else
        do_flush = false
      end

      xsl_body = File.read(xsl_path)
      xsl_doc = Nokogiri::XML(xsl_body)
      xsl_version = xsl_doc.xpath("/*[local-name()='stylesheet' or local-name()='transform']").first['version']
      logger.info("XSLT version: #{xsl_version}")

      cur_dir = Dir.pwd
      Dir.chdir(File.dirname(xsl_path))

      case
      when xsl_version.start_with?('1.')
        if src_doc.nil?
          enc_name = parameters.nil? ? nil : parameters["ENCODING_NAME"]
          enc_name = parameters["ENCODING_NAME"] || "UTF-8"
          enc = Encoding::find(enc_name)
          raise "invalid encoding name #{enc_name}" if enc.nil?

          src_doc = UMPTG::XML.parse(
                  xml_file: src_path,
                  encoding: enc.name
                )
        end

        xsl = Nokogiri::XSLT(xsl_body)
        dest_xml = xsl.transform(src_doc, parameters)
        File.open(dest_path, "w", encoding: src_doc.encoding) {|fp| fp.write(dest_xml) }
      when xsl_version.start_with?('2.')
        raise "srcpath parameter must be set" if src_path.nil? or src_path.empty?
        parameters_str = ""
        parameters.each { |key, val| parameters_str += " #{key}=\"#{val}\""} unless parameters == nil
        if dest_path == nil or dest_path.strip.empty?
          cmd_str = sprintf(@@CMD_STR, @@JAR_PATH, xsl_path, src_path, parameters_str)
        else
          cmd_str = sprintf(@@CMD_STR_DEST, @@JAR_PATH, xsl_path, src_path, dest_path, parameters_str)
        end
        logger.info(cmd_str)

        Open3.popen3(cmd_str) do |stdin, stdout, stderr, thread|
          unless stderr.closed?
            st = stderr.read
            logger.info(st) unless st.empty?
          end
          unless stdout.closed?
            st = stdout.read
            logger.info(st) unless st.empty?
          end
        end
      else
        raise "unknown XSL stylesheet version #{xsl_version}."
        return false
      end

      Dir.chdir(cur_dir)

      return true
    end

    def self.XSL_DIR
      return @@XSL_DIR
    end
  end
end