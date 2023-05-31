module UMPTG::Review
  class EPUBEmbedder < EPUBProcessor

    @@PROCESSORS = {
          resources_embed: ResourceEmbedProcessor.new,
        }

    def initialize(args = {})
      super(args)
      @manifest = args[:manifest]
      @resource_map = args[:resource_map]
      @reference_actions = nil
    end

    def embed(args = {})
      embed_options = args[:embed_options]
      css_file = args[:css_file]

      update_css = !(css_file.nil? or css_file.empty?)

      @reference_actions = UMPTG::Fulcrum::ReferenceActions.new(
                resource_map: @resource_map,
                resource_metadata: @manifest,
                logger: @logger
                )  \
            if @reference_actions.nil?
      processors = @@PROCESSORS.select {|key,proc| embed_options[key] == true }
      processors[:resources_embed].manifest = @manifest if processors.key?(:resources_embed)
      processors[:resources_embed].reference_actions = @reference_actions \
              if processors.key?(:resources_embed)

      # Process the epub and generate the image information.
      @epub_modified = false
      @action_map = UMPTG::EPUB::Processor.process(
            epub: @epub,
            entry_processors: processors,
            pass_xml_doc: true,
            logger: @logger
          )

      @action_map.each do |entry_name,proc_map|
        proc_map.each do |key,action_list|
          next if action_list.nil?
          action_list.each do |action|
            action.process()
          end
        end
      end

      issue_cnt = {
            UMPTG::Message.INFO => 0,
            UMPTG::Message.WARNING => 0,
            UMPTG::Message.ERROR => 0,
            UMPTG::Message.FATAL => 0
      }

      @action_map.each do |entry_name,proc_map|
        @logger.info(entry_name)

        update_entry = false
        proc_map.each do |key,action_list|
          next if action_list.nil?
          action_list.each do |action|
            update_entry = true if action.status == UMPTG::Review::NormalizeAction.NORMALIZED
            action.messages.each do |msg|
              case msg.level
              when UMPTG::Message.INFO
                @logger.info(msg.text)
              when UMPTG::Message.WARNING
                @logger.warn(msg.text)
              when UMPTG::Message.ERROR
                @logger.error(msg.text)
              when UMPTG::Message.FATAL
                @logger.fatal(msg.text)
              end
              issue_cnt[msg.level] += 1
            end
          end
        end
        if update_entry
          @logger.info("Updating entry #{entry_name}")
          xml_doc = proc_map[:xml_doc]

          if update_css
              # Add the CSS stylesheet link that manages the Fulcrum resource display.
              level = File.dirname(entry_name).split(File::SEPARATOR).count
              if level == 1
                UMPTG::XMLUtil.add_css(xml_doc, File.basename(css_file))
              else
                fpath = (('..' + File::SEPARATOR) * (level-1)) + File.basename(css_file)
                UMPTG::XMLUtil.add_css(xml_doc, fpath)
              end
              @logger.info("Added CSS stylesheet \"#{File.basename(css_file)}\".")
          end
          @epub.add(entry_name: entry_name, entry_content: UMPTG::XMLUtil.doc_to_xml(xml_doc))

          @epub_modified = true
        end
      end

      if @epub_modified and update_css
        # xhtml files were modified. Need to update the OPF file.
        opf_doc = epub.opf_doc()

        # Locate the <manifest>.
        manifest_node = opf_doc.xpath("//*[local-name()='manifest']")
        if manifest_node == nil
          @logger.warn("unable to update OPF CSS, no manifest node")
        else
          # Add the manifest entry for the Fulcrum CSS stylesheet.
          # If another CSS stylesheet is present, add it after.
          # Otherwise, add it as last child.
          item_node = opf_doc.create_element(
                  "item",
                  href: File.basename(css_file),
                  :id => "fulcrum_css",
                  )
          item_node['media-type'] = "text/css"

          node_list = manifest_node.xpath("./*[local-name()='item' and @media-type='text/css']")
          if node_list == nil
            manifest_node.add_child(item_node)
          else
            node_list.last.add_next_sibling(item_node)
          end

          # Add the Fulcrum CSS stylesheet
          dest_css_file = File.join(File.dirname(epub.opf_name), File.basename(css_file))
          @epub.add(entry_name: dest_css_file, entry_content: File.read(css_file))

          # Update the OPF file in the EPUB.
          epub.add(entry_name: epub.opf_name, entry_content: UMPTG::XMLUtil.doc_to_xml(opf_doc))

          @logger.info("updated OPF CSS, #{File.basename(css_file)}")
        end
      end

      case
      when issue_cnt[UMPTG::Message.FATAL] > 0
        @logger.fatal("Fatal:#{issue_cnt[UMPTG::Message.FATAL]}  Error:#{issue_cnt[UMPTG::Message.ERROR]}  Warning:#{issue_cnt[UMPTG::Message.WARNING]}")
      when issue_cnt[UMPTG::Message.ERROR] > 0
        @logger.error("Error:#{issue_cnt[UMPTG::Message.ERROR]}  Warning:#{issue_cnt[UMPTG::Message.WARNING]}")
      when issue_cnt[UMPTG::Message.WARNING] > 0
        @logger.warn("Warning:#{issue_cnt[UMPTG::Message.WARNING]}")
      else
        @logger.info("Error: 0")
      end

      unless epub_modified
        @logger.info("Embedding not necessary.")
      end
    end
  end
end
