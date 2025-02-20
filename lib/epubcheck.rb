module UMPTG
  class EPUBCheck
    JAR_PATH = File.join(__dir__, 'epubcheck', 'v%s', 'epubcheck.jar')
    OPTS_STR_VERSION = "--version -q"
    OPTS_STR_EPUB = "-q -o \"%s\" \"%s\""
    OPTS_STR_EPUBDIR = "-q -o \"%s\" -mode exp \"%s\""
    CMD_STR_ALL = "java -jar \"%s\" %s"

    VERSIONS = [
          "4.2.6",
          "5.1.0",
          "5.2.1"
        ]

    def self.check_file(args = {})
      epub_file = args[:epub_file]
      log_file = args[:logfile]
      version = args[:version]

      cmd_str = File.directory?(epub_file) ? OPTS_STR_EPUBDIR : OPTS_STR_EPUB
      java_cmd_str = sprintf(cmd_str, log_file, epub_file)
      execute(
            options: java_cmd_str,
            version: version
          )
    end

    def self.invoke(args = [])
      opts_str = args.count == 0 ? "-h" : args.join(' ')
      execute(
            options: opts_str
          )
    end

    def self.execute(args = {})
      opts_str = args[:options]
      raise "missing options string" if opts_str.nil? or opts_str.strip.empty?

      ver = args[:version]
      ver = versions_default() if ver.nil? or ver.strip.empty?
      jar_path = sprintf(JAR_PATH, ver)
      raise "invalid EPUBCheck version #{jar_path}" unless File.file?(jar_path)

      # Display the version
      if ver[0] =="5"
        # Version 5 will ignore the epub is version option is provided.
        # So, display it first before evaluating the epub.
        java_cmd_str = sprintf(CMD_STR_ALL, jar_path, OPTS_STR_VERSION)
        system(java_cmd_str)
      else
        # Version 4 will display the version and evaluate
        # the epub in the same call.
        opts_str = "--version " + opts_str
      end

      java_cmd_str = sprintf(CMD_STR_ALL, jar_path, opts_str)
      ok = system(java_cmd_str)
      status = $?

      case ok
      when true
      else
      end
    end

    def self.versions
      return VERSIONS
    end

    def self.versions_str(args = {})
      sep = args[:separator]

      sep = "|" if sep.nil? or sep.strip.empty?
      return VERSIONS.join(sep)
    end

    def self.versions_default(args = {})
      return VERSIONS.first
    end
  end
end
