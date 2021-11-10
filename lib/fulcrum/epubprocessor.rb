module UMPTG::Fulcrum

  require 'zip'

  # Class processes the resources found within an EPUB.
  class EPUBProcessor

    @@DEFAULT_ACTIONS = {
            keywords:  [:default, :disable, :link, :none],
            resources: [:default, :disable, :embed, :link, :none, :remove, :update_alt]
          }

    def self.process(args = {})
      # EPUB parameter processing

      #   :logger               Logger for messages
      logger = args[:logger]
      case
      when args.key?(:epub)
        epub = args[:epub]
        logger.fatal("Error: invalid EPUB.") if epub.nil? or epub.class != "UMPTG::EPUB::Archive"
      when args.key?(:epub_file)
        # Create the EPUB from the specified file.
        epub_file = args[:epub_file]
        epub = UMPTG::EPUB::Archive.new(epub_file: epub_file)
      else
        logger.fatal("Error: :epub or :epub_file must be specified")
      end

      # Processing parameters:
      #   :default_actions      Map specifying default processing actions
      #                         :keywords  :disable|:link|:none
      #                         :resources :disable|:embed|:none
      #   :resource_metadata    Monograph resource metadata
      #   :resource_map_file    Monograph resource reference=>fileset mapping
      #   :fulcrum_css_file     CSS file for styling resources with Fulcrum reader
      #                         the references.
      default_actions = args[:default_actions]
      resource_metadata = args[:resource_metadata]
      resource_map_file = args[:resource_map_file]
      fulcrum_css_file = args[:fulcrum_css_file]

      # If processing keywords, need monograph NOID
      # for constructing URLs.
      monograph_noid = args[:monograph_noid]
      logger.fatal("Error: missing keywords processing needs monograph NOID.") \
          if default_actions[:keywords] == :link and monograph_noid.nil?

      # Construct the resource reference to fileset mapping
      logger.info("Using resource map file #{File.basename(resource_map_file)}")
      resource_map = ResourceMap::Map.new(
            :xml_path => resource_map_file,
            :default_action => default_actions[:resources]
          )
      logger.info("Using #{resource_map.vendors[:epub]} processor")

      # Save the resource actions file within a new epub structure
      # for archival purposes.
      epub.add(
            entry_name: File.join("META-INF", "src", File.basename(resource_map_file)),
            entry_content: File.read(resource_map_file)
          )

      # Determine the selector for the resource references. This may be
      # vendor specific.
      reference_selector = Resources::ReferenceSelectorFactory.select(vendor: resource_map.vendors[:epub])

      processors = {}
      unless default_actions[:resources].nil? or default_actions[:resources] == :disable
        # Instantiate the class that will process each resource reference.
        resource_processor = Resources::ResourceProcessor.new(
                    resource_map: resource_map,
                    resource_metadata: resource_metadata,
                    :default_action => default_actions[:resources],
                    selector: reference_selector,
                    logger: logger,
                    )
        processors[:resources] = resource_processor
      end

      unless default_actions[:keywords].nil? or default_actions[:keywords] == :disable
        # Instantiate the class that will process each keyword reference.
        keyword_processor = Keywords::KeywordProcessor.new(
                    monograph_noid: monograph_noid,
                    logger: logger
                    )
        processors[:keywords] = keyword_processor
      end

      # Process the epub. Returned is a hash table where each
      # item key is an EPUB entry name and the item value is
      # a list of processing actions.
      action_map = UMPTG::EPUB::Processor.process(
            epub: epub,
            entry_processors: processors,
            pass_xml_doc: true,
            logger: logger
          )

      # Provide the directory path for adding the CSS stylesheet link.
      # Possible option? Sometimes CSS files are found in a
      # subdirectory from the OPF file, most times it is found
      # in the same directory.
      fulcrum_css_name = File.basename(fulcrum_css_file)
      #fulcrum_css_dir = "../Styles"
      fulcrum_dest_css_dir = "./"
      fulcrum_dest_css_file = File.join(fulcrum_dest_css_dir, fulcrum_css_name)

      # Review each action and determine its success.
      remote_resources_list = []
      update_opf = false
      action_map.each do |entry_name,proc_map|
        # Action list for this EPUB entry. Determine if
        # at least one Action within the list completed
        # successfully.
        logger.info(entry_name)

        xml_doc = proc_map[:xml_doc]
        action_list = proc_map[:resources]
        unless action_list.nil?
          result = false
          action_list.each do |action|
            case action.status
            when UMPTG::Action.COMPLETED
              logger.info(action.to_s)
              result = true
            when UMPTG::Action.FAILED
              logger.error(action.to_s)
            else
              logger.info(action.to_s)
            end
          end

          entry_updated = false
          if result
            # At last one action was completed. Remember that this
            # file was updated.
            #update_opf = true

            # If resources were embedded, then we need to set the
            # remote-resource property in the OPF file.
            update_opf = action_list.index { |action|
                        action.status == UMPTG::Action.COMPLETED and \
                          (
                            action.reference_action_def.action_str == :embed or \
                            action.reference_action_def.action_str == :link
                          )
                        }
            has_remote_resources = action_list.index { |action|
                        action.status == UMPTG::Action.COMPLETED and action.reference_action_def.action_str == :embed
                        }
            if update_opf
              if has_remote_resources
                remote_resources_list << entry_name
              end

              # Add the CSS stylesheet link that manages the Fulcrum resource display.
              level = File.dirname(entry_name).split(File::SEPARATOR).count
              if level == 1
                UMPTG::XMLUtil.add_css(xml_doc, fulcrum_dest_css_file)
              else
                fpath = (('..' + File::SEPARATOR) * (level-1)) + fulcrum_css_name
                UMPTG::XMLUtil.add_css(xml_doc, fpath)
              end
              logger.info("Added CSS stylesheet \"#{fulcrum_css_name}\".")
            end

            # Update the entry in the EPUB. Remove old entry and
            # add the new one.
            entry_updated = true
            epub.add(entry_name: entry_name, entry_content: UMPTG::XMLUtil.doc_to_xml(xml_doc))
          end
        end

        action_list = proc_map[:keywords]
        unless action_list.nil?
          result = false
          action_list.each do |action|
            case action.status
            when UMPTG::Action.COMPLETED
              logger.info(action.to_s)
              result = true
            when UMPTG::Action.FAILED
              logger.error(action.to_s)
            else
              logger.info(action.to_s)
            end
          end
          if result and !entry_updated
            entry_updated = true
            epub.add(entry_name: entry_name, entry_content: UMPTG::XMLUtil.doc_to_xml(xml_doc))
          end
        end
      end

      if update_opf and
        # xhtml files were modified. Need to update the OPF file.
        opf_doc = epub.opf_doc()

        # Locate the <manifest>.
        manifest_node = opf_doc.xpath("//*[local-name()='manifest']")
        if manifest_node == nil
          logger.warn("No manifest node")
        else
          # Add the manifest entry for the Fulcrum CSS stylesheet.
          # If another CSS stylesheet is present, add it after.
          # Otherwise, add it as last child.
          item_node = opf_doc.create_element(
                  "item",
                  :href => fulcrum_dest_css_file,
                  :id => "fulcrum_default",
                  )
          item_node['media-type'] = "text/css"

          node_list = manifest_node.xpath("./*[local-name()='item' and @media-type='text/css']")
          if node_list == nil
            manifest_node.add_child(item_node)
          else
            node_list.last.add_next_sibling(item_node)
          end

          # Add the Fulcrum CSS stylesheet
          dest_css_file = File.join(File.dirname(epub.opf_name), File.basename(fulcrum_css_file))
          epub.add(entry_name: dest_css_file, entry_content: File.read(fulcrum_css_file))
        end

        # Add remote resources to the OPF file.
        logger.info("Adding remote resources to OPF file #{File.basename(epub.opf_name)}")
        remote_resources_list.each do |path|
          path_basename = File.basename(path)
          node_list = opf_doc.xpath("//*[local-name()='manifest']/*[local-name()='item' and contains(@href, '#{path_basename}')]")
          node_list.each do |node|
            if node.has_attribute?("properties")
              node['properties'] += " remote-resources"
            else
              node['properties'] = "remote-resources"
            end
          end
        end

        # Update the OPF file in the EPUB.
        epub.add(entry_name: epub.opf_name, entry_content: UMPTG::XMLUtil.doc_to_xml(opf_doc))
      end

      # Return the possibly modified EPUB
      return epub
    end

    def self.valid_action?(action)
      return @@DEFAULT_ACTIONS[:resources].include?(action)
    end

    def self.DEFAULT_ACTIONS
      return @@DEFAULT_ACTIONS
    end
  end
end
