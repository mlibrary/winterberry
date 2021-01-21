module UMPTG::Resources

  require 'zip'

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

      default_action_str = args[:default_action_str]
      resource_metadata = args[:resource_metadata]
      resource_map_file = args[:resource_map_file]
      fulcrum_css_file = args[:fulcrum_css_file]
      vendor = args[:vendor]

      puts "Using resource map file #{File.basename(resource_map_file)}"
      resource_map = UMPTG::ResourceMap::Map.new(
            :xml_path => resource_map_file,
            :default_action => default_action_str
          )

      # Create the EPUB from the specified file.
      epub = UMPTG::EPUB::Archive.new(:epub_file => epub_file)

      # Save the resource actions file within a new epub structure
      # for archival purposes.
      epub.add(
            entry_name: File.join("META-INF", "src", File.basename(resource_map_file)),
            entry_content: File.read(resource_map_file)
          )

      case vendor
      when 'newgen'
        reference_selector = UMPTG::Resources::NewgenReferenceSelector.new
      else
        reference_selector = UMPTG::Resources::SpecReferenceSelector.new
      end

      reference_processor = UMPTG::Resources::ReferenceProcessor.new(
                  selector: reference_selector
                  )
      resource_processor = UMPTG::Resources::ResourceProcessor.new(
                  resource_map: resource_map,
                  resource_metadata: resource_metadata,
                  default_action_str: default_action_str,
                  reference_processor: reference_processor
                  )

      # Provide the directory path for adding the stylesheet link.
      # Possible option?
      fulcrum_css_name = File.basename(fulcrum_css_file)
      #fulcrum_css_dir = "../Styles"
      fulcrum_dest_css_dir = "./"
      fulcrum_dest_css_file = File.join(fulcrum_dest_css_dir, fulcrum_css_name)

      remote_resources_list = []
      update_opf = false
      spine_items = epub.spine
      spine_items.each do |item|
        puts "Processing file #{item.name}"
        STDOUT.flush

        # Create the XML tree.
        content = item.get_input_stream.read
        begin
          doc = Nokogiri::XML(content, nil, 'UTF-8')
        rescue Exception => e
          puts e.message
          next
        end

        # Determine the list of actions completed.
        # The -e flag must be specified for the actions
        # to be completed.
        action_list = resource_processor.process(doc)
        result = action_list.index { |action| action.status == Action.COMPLETED }
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
            remote_resources_list << item.name
          end

          # Add the CSS stylesheet link that manages the Fulcrum resource display.
          level = File.dirname(item.name).split(File::SEPARATOR).count
          if level == 1
            UMPTG::XMLUtil.add_css(doc, fulcrum_dest_css_file)
          else
            fpath = (('..' + File::SEPARATOR) * (level-1)) + fulcrum_css_name
            UMPTG::XMLUtil.add_css(doc, fpath)
          end
          puts "Added CSS stylesheet \"#{fulcrum_css_name}\"."

          # Update the entry content
          epub.add(entry_name: item.name, entry_content: UMPTG::XMLUtil.doc_to_xml(doc))
        end
        puts "\n"
      end

      if update_opf
        # xhtml files were modified. Need to update the OPF file.
        opf_doc = epub.opf_doc()

        # Locate the <manifest>.
        manifest_node = opf_doc.xpath("//*[local-name()='manifest']")
        if manifest_node == nil
          puts "No manifest node"
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
        puts "Adding remote resources to OPF file #{File.basename(epub.opf_name)}"
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

        # Save the OPF file.
        epub.add(entry_name: epub.opf_name, entry_content: UMPTG::XMLUtil.doc_to_xml(opf_doc))
      end

      # Return the modified EPUB
      return epub
    end
  end
end

