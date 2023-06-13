module UMPTG::Review
  class EPUBUpdater

    require 'css_parser'

    attr_accessor :logger

    def initialize(args = {})
      # Init log file. Use specified path or STDOUT.
      case
      when args.key?(:logger_file)
        logger_file = args[:logger_file]
        @logger = Logger.new(File.open(logger_file, File::WRONLY | File::TRUNC | File::CREAT))
      when args.key?(:logger)
        @logger = args[:logger]
      else
        @logger = Logger.new(STDOUT)
      end
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "#{severity}: #{msg}\n"
      end

      @action_map = {}
    end
    
    def update(args = {})
      # Determine the EPUB to use.
      case
      when args.key?(:epub_file)
        epub = UMPTG::EPUB::Archive.new(epub_file: args[:epub_file])
      when args.key?(:epub)
        epub = args[:epub]
      else
        raise "Error no EPUB specified"
      end

      css_file_list = args[:css_file_list]
      if css_file_list.nil? or css_file_list.empty?
        @logger.error("no CSS file(s) specified.")
        return false
      end
      force_update = args[:css_force_update] || false
      update_navigation = args[:update_navigation] || false
      
      css_file = css_file_list.first
      css_file_name = File.basename(css_file)
      css_content = File.read(css_file)
      css_parser = CssParser::Parser.new
      css_parser.load_string!(css_content)
      css_version = fulcrum_css_version(css_content)
      if css_version.empty?
        @logger.error("Fulcrum version not found for #{File.basename(css_file)}")
        return false
      end
      @logger.info("version #{css_version} found for #{File.basename(css_file)}")
      
      # Traverse the list of EPUB CSS files and attempt
      # to determine the one to replace.
      epub_css_entry_list = {}
      epub.css.each do |epub_css_entry|
        @logger.info("considering CSS file #{epub_css_entry.name}")
  
        # Check to see if this is a Fulcrum CSS stylesheet.
        epub_css_version = fulcrum_css_version(epub_css_entry.content)
        if epub_css_version.empty?
          if force_update
            @logger.warn("appears to not be a Fulcrum CSS stylesheet. Forcing update.")
          else
            @logger.warn("appears to not be a Fulcrum CSS stylesheet. Skipping update.")
            next
          end
        elsif epub_css_version == css_version
          if force_update
            @logger.warn("CSS stylesheet appears to be version #{css_version}. Forcing update.")
          else
            @logger.warn("CSS stylesheet appears to be version #{css_version}. Skipping update.")
            next
          end
        end
        epub_css_entry_list[epub_css_version] = epub_css_entry
        @logger.info("version #{epub_css_version} found.")
      end

      # Traverse the list of EPUB CSS files.
      epub_css_entry_list.each do |epub_css_version,epub_css_entry|
        @logger.info("processing CSS file #{epub_css_entry.name}")
  
        # Parse the CSS stylesheet and attempt to determine
        # which classes are used in the EPUB instances,
        # are defined in the original CSS,
        # but are not defined in the latest version of the CSS.
        # Checking for instances of:
        #   h1 {..}
        #   .my_class {.}
        #   h1.my_class {.}
        # These classes are considered to be necessary.
        epub_css_parser = CssParser::Parser.new
        epub_css_parser.load_string!(epub_css_entry.content)
        rulesets_found = {}

        entry_list = update_navigation ? epub.navigation + epub.spine : epub.spine
        entry_list.each do |epub_entry|
          @logger.info("processing spine entry #{epub_entry.name}")
  
          xml_doc = UMPTG::XMLUtil.parse(xml_content: epub_entry.content)
  
          # Retrieve all class names used in this HTML instance.
          xml_doc.xpath("//*[@class]").each do |node|
            node.classes.each do |cl|
              dot_cl = "." + cl
              elem_dot_cl = node.name + dot_cl
  
              # If this class has been processed, then we can skip it.
              next if rulesets_found.key?(cl) or rulesets_found.key?(dot_cl) or rulesets_found.key?(elem_dot_cl)
  
              # Process this class, starting with
              #   element_name {.} definition.
              key = cl
              epub_css_ruleset = epub_css_parser.find_by_selector(key)
              css_ruleset = css_parser.find_by_selector(key)
              if epub_css_ruleset.empty? and css_ruleset.empty?
  
                # No definitions found for this class in both CSS files. Try
                #   .my_class {.} definition.
                key = dot_cl
                epub_css_ruleset = epub_css_parser.find_by_selector(key)
                css_ruleset = css_parser.find_by_selector(key)
                if epub_css_ruleset.empty? and css_ruleset.empty?
  
                  # No definitions found for this class in both CSS files. Try
                  #   element_name.my_class {.} definition.
                  key = elem_dot_cl
                  epub_css_ruleset = epub_css_parser.find_by_selector(key)
                  css_ruleset = css_parser.find_by_selector(key)
                end
              end
  
              if epub_css_ruleset.empty? and css_ruleset.empty?
                # No definitions found in both CSS files.
                status = :not_found
              elsif epub_css_ruleset.empty?
                # Definition found in the EPUB CSS, but not new CSS.
                status = :new_epub_found
              elsif css_ruleset.empty?
                # No definition found in the EPUB CSS, but found in new CSS.
                status = :epub_found
              else
                # Definition found in both CSS files.
                status = :both_found
              end
  
              # Record the determination to avoid duplication
              # and for later processing.
              rulesets_found[key] = status
            end
          end
  
          # If the name of the CSS file is to change,
          # need to update the reference within this
          # spine entry.
          entry_modified = false
          xpath = "/*[local-name()='html']/*[local-name()='head']/*[local-name()='link' and @type='text/css']"
          xml_doc.xpath(xpath).each do |node|
            entry_css_path = node['href']
            next unless File.basename(entry_css_path) == File.basename(epub_css_entry.name)
  
            new_entry_css_path = File.join(File.dirname(entry_css_path), css_file_name)
            node['href'] = new_entry_css_path
            entry_modified = true
          end
  
          if entry_modified
            epub.add(
                entry_name: epub_entry.name,
                entry_content: UMPTG::XMLUtil.doc_to_xml(xml_doc)
                )
          end
        end
  
        # Determine if any necessary classes were found.
        needed_rulesets = rulesets_found.select {|key,status| status == :epub_found}
        if needed_rulesets.empty?
          # None found.
          @logger.info("no legacy definitions found for inclusion.")
        else
          # Found some. Update the new CSS file with these classes.
          css_content += "\n\n/* Legacy classes from version #{epub_css_version} */\n\n"
          needed_rulesets.each do |key,status|
            @logger.info("adding definition #{key} to new CSS for inclusion.")
            epub_css_ruleset = epub_css_parser.find_by_selector(key)
            css_content += "#{key} {\n\t#{epub_css_ruleset.join("\n")}\n}\n"
          end
        end
  
        # Update the EPUB with the new CSS file.
        # Use the basename of the new CSS file as
        # the name of the updated EPUB CSS file.
        @logger.info("replacing CSS stylesheet #{epub_css_entry.name} version #{epub_css_version} with #{css_version}.")
        #epub.add(entry_name: epub_css_entry.name, entry_content: css_content)
        epub.remove(entry_name: epub_css_entry.name)
        new_entry_name = File.join(File.dirname(epub_css_entry.name), css_file_name)
        epub.add(entry_name: new_entry_name, entry_content: css_content)
      end

      if epub.modified
        # Update the OPF file to have the name
        # of the new CSS file.
        opf_doc = UMPTG::XMLUtil.parse(xml_content: epub.opf.content)
        xpath = "//*[local-name()='manifest']/*[local-name()='item' and @media-type='text/css']"
        opf_doc.xpath(xpath).each do |node|
          href = node['href']
          epub_css_entry_list.each do |epub_css_version,epub_css_entry|
            next unless File.basename(href) == File.basename(epub_css_entry.name)

            node['href'] = File.join(File.dirname(href), css_file_name)
            node['id'] = node['href'].gsub(/[\.\/]+/, '_')
            @logger.info("EPUB OPF entry #{href} updated to #{node['href']}.")
          end
        end
        epub.add(
              entry_name: epub.opf.name,
              entry_content: UMPTG::XMLUtil.doc_to_xml(opf_doc)
              )
        @logger.info("EPUB OPF updated")
      end
      return true
    end
    
    private
    
    def fulcrum_css_version(css_content)
      # Check to see if this is a Fulcrum CSS stylesheet.
      matches = css_content.downcase.match('\/\/[ \t]*about:.*fulcrum[ \t]+')
      return '' if matches.nil?
    
      # Is Fulcrum CSS. Attempt to determine the version.
      matches = css_content.match('\/\/[ \t]+[Vv]ersion[ \t]+([0-9\.]+)')
      return '' if matches.nil?
    
      # Found the version.
      css_version = matches.captures.first
      return css_version
    end
  end
end
