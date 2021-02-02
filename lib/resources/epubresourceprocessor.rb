module UMPTG::Resources

  require 'zip'

  # Class processes the resources found within an EPUB.
  class EpubResourceProcessor
    def self.process(args = {})
      # EPUB parameter processing
      case
      when args.key?(:epub)
        epub = args[:epub]
        raise "Error: invalid EPUB." if epub.nil? or epub.class != "UMPTG::EPUB::Archive"
      when args.key?(:epub_file)
        # Create the EPUB from the specified file.
        epub_file = args[:epub_file]
        epub = UMPTG::EPUB::Archive.new(epub_file: epub_file)
      else
        raise "Error: :epub or :epub_file must be specified"
      end

      # Processing parameters:
      #   Default resource action, embed|link
      #   Monograph resource metadata
      #   Monograph resource reference to fileset mapping
      #   CSS file for styling resources with Fulcrum reader
      #   Vendor that delivered the EPUB, to aid in processing
      #     the references.
      default_action_str = args[:default_action_str]
      resource_metadata = args[:resource_metadata]
      resource_map_file = args[:resource_map_file]
      fulcrum_css_file = args[:fulcrum_css_file]
      vendor = args[:vendor]
      log = args[:log]

      # Construct the resource reference to fileset mapping
      log.puts "Using resource map file #{File.basename(resource_map_file)}"
      resource_map = UMPTG::ResourceMap::Map.new(
            :xml_path => resource_map_file,
            :default_action => default_action_str
          )

      # Save the resource actions file within a new epub structure
      # for archival purposes.
      epub.add(
            entry_name: File.join("META-INF", "src", File.basename(resource_map_file)),
            entry_content: File.read(resource_map_file)
          )

      # Declare the selector for the resource references. This may be
      # vendor specific.
      case vendor
      when 'newgen'
        reference_selector = UMPTG::Resources::NewgenReferenceSelector.new
      else
        reference_selector = UMPTG::Resources::SpecReferenceSelector.new
      end

      # Instantiate the class that will process each resource reference.
      resource_processor = UMPTG::Resources::ResourceProcessor.new(
                  resource_map: resource_map,
                  resource_metadata: resource_metadata,
                  default_action_str: default_action_str,
                  selector: reference_selector
                  )

      # Process the epub. Returned is a hash table where each
      # item key is an EPUB entry name and the item value is
      # a list of processing actions.
      processors = { spec: resource_processor }
      action_map = UMPTG::EPUB::Processor.process(
            epub: epub,
            entry_processors: processors
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
      action_map.each do |entry_name,action_list|
        # Action list for this EPUB entry. Determine if
        # at least one Action within the list completed
        # successfully.
        log.puts entry_name
        result = false

        action_list.each do |action|
          log.puts action
          unless result
            result = action.status == UMPTG::Action.COMPLETED
          end
        end

        if result
          # At last one action was completed. Remember that this
          # file was updated.
          update_opf = true

          # If resources were embedded, then we need to set the
          # remote-resource property in the OPF file.
          has_remote_resources = action_list.index { |action|
                      action.status == Action.COMPLETED and action.reference_action_def.action_str == "embed"
          }
          if has_remote_resources
            remote_resources_list << entry_name
          end

          # Add the CSS stylesheet link that manages the Fulcrum resource display.
          doc = action_list.first.reference_container.document
          level = File.dirname(entry_name).split(File::SEPARATOR).count
          if level == 1
            UMPTG::XMLUtil.add_css(doc, fulcrum_dest_css_file)
          else
            fpath = (('..' + File::SEPARATOR) * (level-1)) + fulcrum_css_name
            UMPTG::XMLUtil.add_css(doc, fpath)
          end
          log.puts "Added CSS stylesheet \"#{fulcrum_css_name}\"."

          # Update the entry in the EPUB. Remove old entry and
          # add the new one.
          epub.remove(entry_name: entry_name)
          epub.add(entry_name: entry_name, entry_content: UMPTG::XMLUtil.doc_to_xml(doc))
        end
      end

      if update_opf
        # xhtml files were modified. Need to update the OPF file.
        opf_doc = epub.opf_doc()

        # Locate the <manifest>.
        manifest_node = opf_doc.xpath("//*[local-name()='manifest']")
        if manifest_node == nil
          log.puts "No manifest node"
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
        log.puts "Adding remote resources to OPF file #{File.basename(epub.opf_name)}"
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
        epub.remove(entry_name: epub.opf_name)
        epub.add(entry_name: epub.opf_name, entry_content: UMPTG::XMLUtil.doc_to_xml(opf_doc))
      end

      # Return the possibly modified EPUB
      return epub
    end
  end
end

